import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import {ChartsComponent} from './charts/charts.component';

const routes: Routes = [
  {
    path: 'charts',
    component: ChartsComponent
  },
  { path: '**',
    redirectTo: '/charts',
    pathMatch: 'full'
  },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
