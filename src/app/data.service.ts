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

  public get():Observable<any[]> {
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
              if (index !== 0) {
                const name = row[3];
                const value = parseInt(row[4]);

                if (typeof name === 'string' && typeof value === 'number') {
                  let entry = results.find(
                    (result: any) => {
                      return result.name === name;
                    }
                  );

                  if (!entry) {
                    entry = {
                      name: name,
                      search: new URL("https://google.com/?" + name),
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

          return results;
        }
      )
    );
  }
}
