import {Component} from '@angular/core';
import {finalize} from 'rxjs/operators';
import {DataService} from '../data.service';
import {EntryModel} from '../entry.model';

@Component({
  selector: 'app-charts',
  templateUrl: './charts.component.html',
  styleUrls: ['./charts.component.scss']
})
export class ChartsComponent {
  public display: string = 'graph';
  public isLoading: boolean = true;

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

  reset():void {
    this.data = 'soliantInvoice';
    this.displayValues = [];
    this.results = [];
    this.types = ['fields'];
  }
}
