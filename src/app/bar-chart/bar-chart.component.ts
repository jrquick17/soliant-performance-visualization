import {Component} from '@angular/core';
import {finalize} from "rxjs/operators";
import {DataService} from "../data.service";

@Component({
  selector: 'app-bar-chart',
  templateUrl: './bar-chart.component.html',
  styleUrls: ['./bar-chart.component.scss']
})
export class BarChartComponent {
  isLoading: boolean = true;
  results: any = [];
  xAxisLabel = 'Fields';
  yAxisLabel = 'Avg (MS)';

  constructor(
    private data:DataService
  ) {
    this.loadData();
  }

  loadData() {
    this.isLoading = true;

    this.data.get().pipe(
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
    console.log(event);
  }
}
