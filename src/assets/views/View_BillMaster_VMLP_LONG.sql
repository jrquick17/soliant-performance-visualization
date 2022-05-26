SELECT bm.billMasterID
     , bm.billableChargeID
     , bm.billingSyncBatchID
     , bm.earnCodeID
     , bm.transactionDate
     , bm.canInvoice
     , bm.dateAdded
     , bm.dateLastModified
     , bm.userID
     , bm.locationID
     , bm.chargeTypeLookupID
     , bm.externalID
     , bm.payBillCycleID
     , bm.billingCalendarInstanceID
     , bm.transactionStatusID
     , bm.isEligibleOverride
     , bm.billMasterStatusLookupID
     , bm.endDate
FROM BULLHORN1.BH_BillMaster bm WITH (NOLOCK)
;
