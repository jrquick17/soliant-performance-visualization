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
  public display: string = 'graph';
  public isLoading: boolean = true;
  public xAxisLabel = 'Fields';
  public yAxisLabel = 'Avg (MS)';

  public data!: string;
  public displayValues!: any[];
  public results!: EntryModel[];
  public types!: string[];
  public uniqueValues!: any[];

  constructor(
    private dataService: DataService
  ) {
    this.reset();
    this.loadData();
  }

  changeData(data: string): void {
    this.data = data;
  }

  changeDisplay(display: string): void {
    this.display = display;
  }

  hasType(type: string): boolean {
    return this.types.some(
      (candidate: string) => {
        return candidate === type;
      }
    );
  }

  toggleType(type: string): void {
    const hasType = this.hasType(type);
    if (hasType) {
      this.types = this.types.filter(
        (candidate: string) => {
          return candidate === type;
        }
      );
    } else {
      this.types.push(type);
    }
  }

  loadData(): void {
    this.isLoading = true;

    this.dataService.get(
      {
        data: this.data,
        types: this.types
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

        this.displayValues = [];
        this.uniqueValues = [];
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

  reset():void {
    this.data = 'soliantInvoice';
    this.displayValues = [];
    this.results = [];
    this.types = ['fields'];
    this.uniqueValues = [];
  }
}
