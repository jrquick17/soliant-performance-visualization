import { Injectable } from '@angular/core';
import {finalize, map, tap} from "rxjs/operators";
import {HttpClient} from "@angular/common/http";
import {NgxCsvParser} from "ngx-csv-parser";
import {Observable} from "rxjs";

@Injectable({
  providedIn: 'root'
})
export class DataService {
  constructor(
    private http:HttpClient,
    private ngxCsvParser: NgxCsvParser
  ) {

  }

  private getParamValues(key:string, query:string, split:string = ',') {
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
        .replace('"', '');

      results = results.concat(fields.split(split));
    }

    return results;
  }

  private getFieldNames(query:string) {
    return this.getParamValues('fields=', query);
  }

  private getWhereNames(query:string) {
    const results:any[] = this.getParamValues('where=', query, ' AND ');

    results.forEach(
      (result) => {
        result = result.splice(result.indexOf('<'));
        result = result.splice(result.indexOf('>'));
        result = result.splice(result.indexOf('!'));
        result = result.splice(result.indexOf('='));
      }
    );

    return results;
  }

  private getShowName(query:string) {
    return this.getParamValues('showTotalMatched=', query);
  }

  private getOrderByName(query:string) {
    return this.getParamValues('orderBy=', query);
  }

  private getGroupByName(query:string) {
    return this.getParamValues('groupBy=', query);
  }

  private getUniqueCallID(query:string) {
    return this.getParamValues('uniqueCallId=', query);
  }

  private getCountName(query:string) {
    return this.getParamValues('count=', query);
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
          const csv = this.ngxCsvParser.csvStringToArray(file, ",");
          csv.forEach(
            (row, index) => {
              row[3] = decodeURIComponent(row[3]);

              if (index !== 0 && typeof row[4] === 'string' && typeof row[3] === 'string') {
                let names:any[] = [];
                switch (type) {
                  case 'count':
                    names = this.getCountName(row[3]);
                    break;
                  case 'fields':
                    names = this.getFieldNames(row[3]);
                    break;
                  case 'groupBy':
                    names = this.getGroupByName(row[3]);
                    break;
                  case 'orderBy':
                    names = this.getOrderByName(row[3]);
                    break;
                  case 'showTotalMatched':
                    names = this.getShowName(row[3]);
                    break;
                  case 'where':
                    names = this.getWhereNames(row[3]);
                    break;
                }

                const value = parseInt(row[4].replace(',', ''));

                if (names.length !== 0) {
                  names.forEach(
                    (name) => {
                      let entry = results.find(
                        (result: any) => {
                          return result.name === name;
                        }
                      );

                      if (!entry) {
                        entry = {
                          name: name,
                          query: row[3],
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

                      const uniqueIDs:string[] = this.getUniqueCallID(row[3]);
                      if (uniqueIDs.length !== 0) {
                        entry.uniqueIDs.push(uniqueIDs[0]);
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
}
