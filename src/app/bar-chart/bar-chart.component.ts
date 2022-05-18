import {Component} from '@angular/core';
import {finalize} from "rxjs/operators";
import {DataService} from "../data.service";
import {EntryModel} from "../entry.model";

@Component({
  selector: 'app-bar-chart',
  templateUrl: './bar-chart.component.html',
  styleUrls: ['./bar-chart.component.scss']
})
export class BarChartComponent {
  chartHeight = 1000;
  chartWidth = 1500;
  displayValues: any[] = [];
  uniqueValues: any[] = [];
  isLoading: boolean = true;
  results: EntryModel[] = [];
  type: string = 'fields';
  xAxisLabel = 'Fields';
  yAxisLabel = 'Avg (MS)';

  constructor(
    private data: DataService
  ) {
    this.loadData();
  }

  changeType(type: string): void {
    this.type = type;

    this.loadData();
  }

  loadData(): void {
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

  onSelect(event: { name: string }): void {
    let entry = this.results.find(
      (result) => {
        return result.name === event.name;
      }
    );

    if (entry) {
      this.displayValues = entry.data;
      this.uniqueValues = entry.uniqueIDs;
    }
  }
}
