import {Component} from '@angular/core';
import {finalize} from "rxjs/operators";
import {DataService} from "../data.service";

@Component({
  selector: 'app-bar-chart',
  templateUrl: './bar-chart.component.html',
  styleUrls: ['./bar-chart.component.scss']
})
export class BarChartComponent {
  displayValues: any[] = [];
  isLoading: boolean = true;
  results: any = [];
  type:string = 'fields';
  xAxisLabel = 'Fields';
  yAxisLabel = 'Avg (MS)';

  constructor(
    private data:DataService
  ) {
    this.loadData();
  }

  changeType(type:string) {
    this.type = type;

    this.loadData();
  }

  loadData() {
    this.isLoading = true;

    this.data.get(this.type).pipe(
      finalize(
        () => {
          this.isLoading = false;
        }
      )
    ).subscribe(
      (results) => {
        this.results = results;
      }
    );
  }

  onSelect(event: any) {
    let entry = this.results.find(
      (result: any) => {
        return result.name === event.name;
      }
    );

    this.displayValues = entry.data;
  }
}
