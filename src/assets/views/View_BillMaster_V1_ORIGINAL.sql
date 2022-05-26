SELECT bm.billMasterID
     , bm.billableChargeID
     , bm.billingSyncBatchID
     , bm.earnCodeID
     , bm.transactionDate
     , CASE
         WHEN
             (
               SELECT SUM
                        (
                        CASE
                          WHEN
                            (
                                bmt.invoiceStatementBatchID IS NULL
                                AND bmt.invoiceStatementID IS NULL
                              )
                            THEN 1
                          ELSE 0
                          END
                        ) AS invoiceableTransactions
               FROM BH_BillMasterTransaction bmt WITH (NOLOCK)
               WHERE bmt.billmasterID = bm.billMasterID
             ) > 0
           THEN CAST(1 AS BIT)
         ELSE CAST(0 AS BIT)
  END AS canInvoice
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
     , CASE
         WHEN ci.endDate >= CAST(GETDATE() AS DATE)
           THEN 0
         ELSE 1
  END AS isEligible
FROM BULLHORN1.BH_BillMaster bm WITH (NOLOCK)
       LEFT JOIN BULLHORN1.BH_CalendarInstance ci WITH (NOLOCK)
                 ON ci.calendarInstanceID = bm.billingCalendarInstanceID
;
