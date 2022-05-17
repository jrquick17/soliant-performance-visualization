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
    let orderBy = query.slice(query.indexOf('&orderBy=') + 9);

    orderBy = orderBy.slice(0, orderBy.indexOf('&'))
      .replace('-', '')
      .replace('+', '');

    return orderBy;
  }

  public get(type:string):Observable<any[]> {
    let results:any[] = [];

    return this.http.get(
      'assets/data.csv',
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
                const name = this.getOrderByName(row[3]);
                const value = parseInt(row[4]);

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
                      value: 0
                    };

                    results.push(entry);
                  }

                  entry.count++;
                  entry.total += value;
                  entry.value = entry.total / entry.count;
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
