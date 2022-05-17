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

  private getOrderByName(query:string) {
    let results = [];

    const startingIndex = query.indexOf('&orderBy=');
    if (startingIndex > 0) {
      let orderBy = query.slice(startingIndex + 9);

      const lastIndex = orderBy.indexOf('&');
      if (lastIndex > 0) {
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
              if (index !== 0 && typeof row[3] === 'string') {
                const names = this.getOrderByName(row[3]);
                const value = parseInt(row[4]);

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
