import {Component, Input} from '@angular/core';
import {EntryModel} from '../entry.model';

@Component({
  selector: 'app-common-requests',
  templateUrl: './common-requests.component.html',
  styleUrls: ['./common-requests.component.scss']
})
export class CommonRequestsComponent {
  @Input() public chartHeight = 1000;
  @Input() public chartWidth = 1500;
  @Input() public display = 'graph';
  @Input() public xAxisLabel = 'Fields';
  @Input() public yAxisLabel = 'Count';

  @Input() public displayValues: any[] = [];
  @Input() public results: EntryModel[] = [];
  @Input() public uniqueValues: string[] = [];

  public view:[number,number] = [innerWidth, innerHeight - 250];

  constructor() {

  }

  onResize(event:any):void {
    this.view = [event.target.innerWidth, event.target.innerHeight - 250];
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
