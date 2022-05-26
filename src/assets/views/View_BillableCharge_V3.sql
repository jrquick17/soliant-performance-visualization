SELECT charge.billableChargeID
     , charge.placementID
     , charge.billingProfileID
     , charge.readyToBillOverride
     , charge.periodEndDate
     , charge.description
     , charge.dateAdded
     , charge.dateLastModified
     , charge.generalLedgerSegment1ID
     , charge.generalLedgerSegment2ID
     , charge.generalLedgerSegment3ID
     , charge.generalLedgerSegment4ID
     , charge.generalLedgerSegment5ID
     , charge.addedByUserID
     , charge.generalLedgerServiceCodeID
     , charge.entryTypeLookupID
     , charge.externalID
     , charge.timeAndExpenseBranch
     , grouped.generalLedgerStatus
     , grouped.markAsReadyEligible
     , grouped.billableChargeStatusLookupID
     , grouped.subtotal
     , grouped.currencyUnitID
     , grouped.transactionStatusID
     , grouped.candidateUserID
     , grouped.isInvoiced
     , grouped.transactionTypeID
     , grouped.clientCorporationID
     , grouped.billingCorporateUserID
     , grouped.billingClientCorporationID
     , grouped.billingClientUserID
     , grouped.invoiceTermID
     , grouped.billingScheduleID
     , grouped.jobPostingID
     , grouped.billingFrequency,
       grouped.billableChargeStatusLookupID
     , grouped.subtotal
     , grouped.currencyUnitID
     , grouped.transactionStatusID
     , grouped.candidateUserID
     , grouped.isInvoiced
     , grouped.transactionTypeID
     , grouped.clientCorporationID
     , grouped.billingCorporateUserID
     , grouped.billingClientCorporationID
     , grouped.billingClientUserID
     , grouped.invoiceTermID
     , grouped.billingScheduleID
     , grouped.jobPostingID
     , grouped.billingFrequency
FROM Bullhorn1.BH_BillableCharge charge
       JOIN Bullhorn1.View_BCGrouped AS grouped
     ON grouped.billableChargeID = charge.billableChargeID
;
