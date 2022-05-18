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
  public chartHeight = 1000;
  public chartWidth = 1500;
  public displayValues: any[] = [];
  public uniqueValues: any[] = [];
  public isLoading: boolean = true;
  public results: EntryModel[] = [];
  public data: string = 'soliantInvoice';
  public type: string = 'fields';
  public xAxisLabel = 'Fields';
  public yAxisLabel = 'Avg (MS)';

  constructor(
    private dataService: DataService
  ) {
    this.loadData();
  }

  changeData(data: string): void {
    this.data = data;

    this.loadData();
  }

  changeType(type: string): void {
    this.type = type;

    this.loadData();
  }

  loadData(): void {
    this.isLoading = true;

    this.dataService.get(
      {
        data: this.data,
        type: this.type
      }
    ).pipe(
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
