import {Injectable} from '@angular/core';
import {map} from 'rxjs/operators';
import {HttpClient} from '@angular/common/http';
import {NgxCsvParser} from 'ngx-csv-parser';
import {forkJoin, Observable} from 'rxjs';
import {EntryModel} from './entry.model';
import {DataServiceSettingsModel} from './data-service-settings.model';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private excludedFields: string[] = [
    'count(id)'
  ];

  constructor(
    private http: HttpClient,
    private ngxCsvParser: NgxCsvParser
  ) {

  }

  public get(settings: DataServiceSettingsModel): Observable<EntryModel[]> {
    const observables: Observable<EntryModel[]>[] = [];

    settings.types.forEach(
      (type) => {
        const observable: Observable<EntryModel[]> = this.http.get(
          'assets/logs/' + settings.data + '.csv',
          {
            responseType: 'text'
          }
        ).pipe(
          map(
            (results) => {
              return this._parseCsv(results, type)
            }
          )
        );

        observables.push(observable);
      }
    );

    return forkJoin(observables).pipe(
      map(
        (allResults: EntryModel[][]) => {
          while (allResults.length !== 1) {
            const lastResult = allResults.pop();
            if (!lastResult) {
              throw 'You done mess up A-A-Ron!';
            }

            lastResult.forEach(
              (fromLast) => {
                const fromFirst = allResults[0].find(
                  (fromFirstCandidate) => {
                    return fromFirstCandidate.name === fromLast.name;
                  }
                );

                if (!fromFirst) {
                  allResults[0].push(fromLast);

                  return;
                }

                fromFirst.count += fromLast.count;
                fromFirst.total += fromLast.total;
                fromFirst.value = fromFirst.total / fromFirst.count;
                fromFirst.data = Array.from(new Set(fromFirst.data.concat(fromLast.data)));
                fromFirst.uniqueIDs = Array.from(new Set(fromFirst.uniqueIDs.concat(fromLast.uniqueIDs)));
              }
            );
          }

          return allResults[0];
        }
      )
    ).pipe(
      map(
        (results) => {
          results = results.sort(
            (a: any, b: any) => {
              if (a.value == b.value) {
                return 0;
              }

              return (a.value < b.value) ? 1 : -1;
            }
          );

          results = results.slice(0, 30);

          return results;
        }
      )
    );
  }

  private static getCountName(query: string): string[] {
    return DataService._getParamValues('count=', query);
  }

  private static _getFieldNames(query: string): string[] {
    return DataService._getParamValues('fields=', query);
  }

  private static getGroupByName(query: string): string[] {
    return DataService._getParamValues('groupBy=', query);
  }

  private static _getNames(type: string, query: string): string[] {
    let names: string[] = [];
    switch (type) {
      case 'count':
        names = DataService.getCountName(query);
        break;
      case 'fields':
        names = DataService._getFieldNames(query);
        break;
      case 'groupBy':
        names = DataService.getGroupByName(query);
        break;
      case 'orderBy':
        names = DataService.getOrderByName(query);
        break;
      case 'showTotalMatched':
        names = DataService.getShowName(query);
        break;
      case 'where':
        names = DataService._getWhereNames(query);
        break;
    }

    return names;
  }

  private static getOrderByName(query: string): string[] {
    return DataService._getParamValues('orderBy=', query);
  }

  private static _getParamValues(key: string, query: string, split: string = ','): string[] {
    let results: any[] = [];

    const startingIndex = query.indexOf(key);
    if (startingIndex >= 0) {
      let fields = query.slice(startingIndex + key.length);

      const lastIndex = fields.indexOf('&');
      if (lastIndex >= 0) {
        fields = fields.slice(0, lastIndex);
      }

      fields = fields.replace('-', '')
        .replace('+', '')
        .replace(')', '')
        .replace('(', '')
        .replace(',', '')
        .replace('\'', '');

      results = results.concat(fields.split(split));
    }

    return results;
  }

  private static getShowName(query: string): string[] {
    return DataService._getParamValues('showTotalMatched=', query);
  }

  private static getUniqueCallID(query: string): string[] {
    return DataService._getParamValues('uniqueCallId=', query);
  }

  private static _getWhereNames(query: string): string[] {
    let results: any[] = DataService._getParamValues('where=', query, ' AND ');

    results = results.map(
      (result) => {
        result = result.split(' ')[0];
        result = result.split(':')[0];
        result = result.split('.')[0];
        result = result.split('<')[0];
        result = result.split('>')[0];
        result = result.split('!')[0];
        result = result.split('=')[0];

        return result;
      }
    );

    return results;
  }

  private _isExcludedField(field: string): boolean {
    return this.excludedFields.some(
      (blacklistedField) => {
        return blacklistedField.toLowerCase() === field.toLowerCase();
      }
    );
  }

  private _parseCsv(csvString: string, type: string): EntryModel[] {
    let results: EntryModel[] = [];

    const csv = this.ngxCsvParser.csvStringToArray(csvString, ',');
    csv.forEach(
      (row, index) => {
        if (index === 0) {
          return;
        } else if (row.length !== 5) {
          return;
        }

        let query = row[3];
        try {
          query = decodeURIComponent(query);
        } catch (_) {
          return;
        }

        let value = row[4];
        if (typeof value !== 'string') {
          return;
        }
        value = parseInt(value.replace(',', ''));

        let names = DataService._getNames(type, query);

        if (names.length !== 0) {
          names.forEach(
            (name: string) => {
              if (this._isExcludedField(name)) {
                return;
              }

              let entry: EntryModel | undefined = results.find(
                (result: any) => {
                  return result.name === name;
                }
              );

              if (!entry) {
                entry = {
                  name: name,
                  query: query,
                  count: 0,
                  total: 0,
                  value: 0,
                  data: [],
                  uniqueIDs: []
                };

                results.push(entry);
              }

              entry.count++;
              entry.total += value;
              entry.value = entry.total / entry.count;

              entry.data.push(JSON.stringify(row));

              const uniqueIDs: string[] = DataService.getUniqueCallID(query);
              if (uniqueIDs.length !== 0) {
                entry.uniqueIDs.push(uniqueIDs[0]);
              }
            }
          );
        }
      }
    );

    return results;
  }
}
