import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CommonRequestsComponent } from './common-requests.component';

describe('BarChartComponent', () => {
  let component: CommonRequestsComponent;
  let fixture: ComponentFixture<CommonRequestsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CommonRequestsComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CommonRequestsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
