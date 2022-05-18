import { Injectable } from '@angular/core';
import {map} from 'rxjs/operators';
import {HttpClient} from '@angular/common/http';
import {NgxCsvParser} from 'ngx-csv-parser';
import {Observable} from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private excludedFields:string[] = [
    'count(id)'
  ];

  constructor(
    private http:HttpClient,
    private ngxCsvParser:NgxCsvParser
  ) {

  }

  public get(type:string):Observable<any[]> {
    let results:any[] = [];

    return this.http.get(
      'assets/dataAll.csv',
      {
        responseType: 'text'
      }
    ).pipe(
      map(
        (file) => {
          const csv = this.ngxCsvParser.csvStringToArray(file, ',');
          csv.forEach(
            (row, index) => {
              const query = decodeURIComponent(row[3]);

              if (index !== 0 && typeof row[4] === 'string') {
                let names = DataService._getNames(type, query);
                const value = parseInt(row[4].replace(',', ''));

                if (names.length !== 0) {
                  names.forEach(
                    (name:string) => {
                      if (!this._isExcludedField(name)) {
                        let entry = results.find(
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

                        entry.data.push(file);

                        const uniqueIDs: string[] = DataService.getUniqueCallID(query);
                        if (uniqueIDs.length !== 0) {
                          entry.uniqueIDs.push(uniqueIDs[0]);
                        }
                      }
                    }
                  );
                }
              }
            }
          );

          results = results.sort(
            (a:any, b:any) => {
              if (a.value == b.value) {
                return 0;
              }

              return (a.value < b.value) ? 1 : -1;
            }
          );

          results = results.slice(0, 30);

          console.log(results);

          return results;
        }
      )
    );
  }

  private static getCountName(query:string) {
    return DataService._getParamValues('count=', query);
  }

  private static _getFieldNames(query:string) {
    return DataService._getParamValues('fields=', query);
  }

  private static getGroupByName(query:string) {
    return DataService._getParamValues('groupBy=', query);
  }

  private static _getNames(type: string, query: string):string[] {
    let names:string[] = [];
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

  private static getOrderByName(query:string) {
    return DataService._getParamValues('orderBy=', query);
  }

  private static _getParamValues(key:string, query:string, split:string = ',') {
    let results:any[] = [];

    const startingIndex = query.indexOf(key);
    if (startingIndex >= 0) {
      let fields = query.slice(startingIndex + key.length);

      const lastIndex = fields.indexOf('&');
      if (lastIndex >= 0) {
        fields = fields.slice(0, lastIndex);
      }

      fields = fields.replace('-', '')
        .replace('+', '')
        .replace('\'', '');

      results = results.concat(fields.split(split));
    }

    return results;
  }

  private static getShowName(query:string) {
    return DataService._getParamValues('showTotalMatched=', query);
  }

  private static getUniqueCallID(query:string) {
    return DataService._getParamValues('uniqueCallId=', query);
  }

  private static _getWhereNames(query:string) {
    const results:any[] = DataService._getParamValues('where=', query, ' AND ');

    results.forEach(
      (result) => {
        result = result.splice(result.indexOf('<'));
        result = result.splice(result.indexOf('>'));
        result = result.splice(result.indexOf('!'));
        result = result.splice(result.indexOf('='));

        return result;
      }
    );

    return results;
  }

  private _isExcludedField(field:string):boolean {
    return this.excludedFields.some(
      (blacklistedField) => {
        return blacklistedField.toLowerCase() === field.toLowerCase();
      }
    );
  }
}
