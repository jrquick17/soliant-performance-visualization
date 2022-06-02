import {NgModule} from '@angular/core';
import {BrowserModule} from '@angular/platform-browser';

import {AppRoutingModule} from './app-routing.module';
import {AppComponent} from './app.component';
import {FieldPerformanceComponent} from './field-performance/field-performance.component';
import {BarChartModule, NgxChartsModule} from '@swimlane/ngx-charts';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';
import {HttpClientModule} from '@angular/common/http';
import {NgxCsvParserModule} from 'ngx-csv-parser';
import {DataService} from './data.service';
import {ChartsComponent} from './charts/charts.component';

@NgModule({
  declarations: [
    AppComponent,
    FieldPerformanceComponent,
    ChartsComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    HttpClientModule,
    BarChartModule,
    NgxChartsModule,
    NgxCsvParserModule
  ],
  providers: [
    DataService
  ],
  bootstrap: [AppComponent]
})
export class AppModule {
}
