import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FieldPerformanceComponent } from './field-performance.component';

describe('BarChartComponent', () => {
  let component: FieldPerformanceComponent;
  let fixture: ComponentFixture<FieldPerformanceComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ FieldPerformanceComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(FieldPerformanceComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
