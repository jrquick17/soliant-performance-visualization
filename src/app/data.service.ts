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

  private getFieldNames(query:string) {
    let results:any[] = [];

    const startingIndex = query.indexOf('fields=');
    if (startingIndex >= 0) {
      let fields = query.slice(startingIndex + 7);

      const lastIndex = fields.indexOf('&');
      if (lastIndex >= 0) {
        fields = fields.slice(0, lastIndex);
      }

      results = results.concat(fields.split(','));
    }

    return results;
  }

  private getOrderByName(query:string) {
    let results = [];

    const startingIndex = query.indexOf('orderBy=');
    if (startingIndex >= 0) {
      let orderBy = query.slice(startingIndex + 8);

      const lastIndex = orderBy.indexOf('&');
      if (lastIndex >= 0) {
        orderBy = orderBy.slice(0, lastIndex);
      }

      orderBy =  orderBy.replace('-', '').replace('+', '');

      results.push(orderBy);
    }

    return results;
  }

  private getCountName(query:string) {
    let results = [];

    const startingIndex = query.indexOf('count=');
    if (startingIndex >= 0) {
      let orderBy = query.slice(startingIndex + 6);

      const lastIndex = orderBy.indexOf('&');
      if (lastIndex >= 0) {
        orderBy = orderBy.slice(0, lastIndex);
      }

      orderBy =  orderBy.replace('-', '').replace('+', '');

      results.push(orderBy);
    }

    return results;
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
                  case 'orderBy':
                    names = this.getOrderByName(row[3]);
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
                          data: []
                        };

                        results.push(entry);
                      }

                      entry.count++;
                      entry.total += value;
                      entry.value = entry.total / entry.count;

                      entry.data.push(file);
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

          results = results.splice(0, 25);

          console.log(results);

          return results;
        }
      )
    );
  }
}
