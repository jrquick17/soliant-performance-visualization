import {Component, Input} from '@angular/core';
import {EntryModel} from '../entry.model';

@Component({
  selector: 'app-bar-chart',
  templateUrl: './bar-chart.component.html',
  styleUrls: ['./bar-chart.component.scss']
})
export class BarChartComponent {
  @Input() public chartHeight = 1000;
  @Input() public chartWidth = 1500;
  @Input() public xAxisLabel = 'Fields';
  @Input() public yAxisLabel = 'Avg (MS)';

  @Input() public displayValues: any[] = [];
  @Input() public results: EntryModel[] = [];
  @Input() public uniqueValues: string[] = [];

  public display = 'graph';

  constructor() {

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
    this.displayValues = [];
    this.results = [];
    this.uniqueValues = [];
  }
}
