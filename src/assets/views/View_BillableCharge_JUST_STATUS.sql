use BULLHORN12474;

SELECT grouped.billableChargeID,
       grouped.billableChargeStatusLookupID
FROM Bullhorn1.BH_BillableCharge charge
       JOIN (
  SELECT innerGrouped.billableChargeID
       , CASE
           WHEN SUM
                  (
                  CASE
                    WHEN innerGrouped.billMasterStatusLookupID = 2 -- Sync Failed
                      THEN 1
                    ELSE 0
                    END
                  ) > 0 -- if any bill masters are in 'Sync Failed' status
             THEN 8 --Processing Failed
           WHEN SUM
                  (
                  CASE
                    WHEN innerGrouped.invoiceStatementBatchID IS NOT NULL AND
                         innerGrouped.invoiceStatementLineItemID IS NULL --if any records have batch but no line item
                      THEN 1
                    WHEN innerGrouped.billMasterStatusLookupID = 1 -- if any bill masters are in 'Syncing' status
                      THEN 1
                    ELSE 0
                    END
                  ) > 0
             THEN 3 --Processing
           WHEN MIN(innerGrouped.batchStatusLookupID) <= 2
             THEN 3 --Processing
           WHEN SUM
                  (
                  CASE
                    WHEN
                          innerGrouped.needsReview = 1
                        AND innerGrouped.invoiceStatementID IS NULL
                        AND innerGrouped.transactionTypeID <> 6 -- Unbillable
                        AND innerGrouped.wasUnbilled = 0
                      THEN 1
                    ELSE 0
                    END
                  ) > 0 --if any INVOICEABLE transactions have needsReview set
             THEN 4 --Needs Review
           WHEN
             (COUNT(*) = SUM
               (
               CASE
                 WHEN innerGrouped.invoiceStatementID IS NOT NULL
                   THEN 1
                 WHEN innerGrouped.transactionTypeID = 6 -- Unbillable
                   THEN 1
                 WHEN innerGrouped.wasUnbilled = 1
                   THEN 1
                 ELSE 0
                 END
               )
               )
             THEN
             (
               CASE
                 WHEN COUNT(innerGrouped.invoiceStatementID) > 0
                   THEN
                   (
                     CASE
                       WHEN SUM(CASE WHEN innerGrouped.isFinalized = 0 THEN 1 ELSE 0 END) > 0
                         THEN 5 --Invoicing
                       ELSE 6 --Invoiced
                       END
                     )
                 ELSE 7 -- Unbillable
                 END
               )
           WHEN
             (
                   SUM
                     (
                     CASE
                       WHEN innerGrouped.isEligible = 0 AND innerGrouped.isEligibleOverride = 0
                         THEN 0
                       WHEN (CAST(innerGrouped.invoiceApprovedTimecardsRequired AS INT) = 0)
                         THEN 1
                       WHEN innerGrouped.readyToBillOverride = 1
                         THEN 1
                       WHEN innerGrouped.invoiceStatementID IS NOT NULL
                         THEN 1
                       WHEN innerGrouped.transactionStatusID = 4 -- Approved
                         THEN 1
                       WHEN innerGrouped.transactionTypeID = 6 -- Unbillable
                         THEN 1
                       WHEN innerGrouped.wasUnbilled = 1
                         THEN 1
                       ELSE 0
                       END
                     ) > 0 -- All eligible transactions are Approved, Invoiced of Unbillable
                 AND SUM(
                       CASE
                         WHEN innerGrouped.isEligible = 0 AND innerGrouped.isEligibleOverride = 0
                           THEN 0
                         WHEN innerGrouped.invoiceStatementID IS NOT NULL
                           THEN 0
                         WHEN innerGrouped.transactionTypeID = 6 -- Unbillable
                           THEN 0
                         WHEN innerGrouped.wasUnbilled = 1
                           THEN 0
                         WHEN (CAST(innerGrouped.invoiceApprovedTimecardsRequired AS INT) = 0)
                           THEN 1
                         WHEN innerGrouped.readyToBillOverride = 1
                           THEN 1
                         WHEN innerGrouped.transactionStatusID = 4 -- Approved
                           THEN 1
                         ELSE 0
                         END
                       ) > 0 -- Any eligible transactions are Approved and not yet invoiced
                 AND SUM(
                       CASE
                         WHEN innerGrouped.billMasterStatusLookupID = 3 -- Synced
                           THEN 1
                         ELSE 0
                         END
                       ) =
                     COUNT(innerGrouped.billMasterStatusLookupID) -- All billMasters need to be in Synced status
               )
             THEN 2 --Ready to Bill
           ELSE 1 --Not Ready to Bill
    END AS billableChargeStatusLookupID
  FROM (
         SELECT innerCharge.billableChargeID
              , innerCharge.readyToBillOverride
              , billMasterTran.invoiceStatementBatchID
              , billMasterTran.invoiceStatementLineItemID
              , billMaster.transactionStatusID
              , invoice.isFinalized
              , billMaster.isEligible
              , billMaster.isEligibleOverride
              , invTerm.invoiceApprovedTimecardsRequired
              , billMasterTran.invoiceStatementID
              , billMasterTran.transactionTypeID
              , billMasterTran.needsReview
              , CASE WHEN billMasterReversedBy.transactionTypeID IS NOT NULL THEN 1 ELSE 0 END AS wasUnbilled
              , (
           SELECT MIN(isb.batchStatusLookupID)
           FROM Bullhorn1.BH_InvoiceStatementBatchBillableCharge isbbc
                  LEFT JOIN Bullhorn1.BH_InvoiceStatementBatch isb
                            ON isb.invoiceStatementBatchID = isbbc.invoiceStatementBatchID
           WHERE isbbc.billableChargeID = innerCharge.billableChargeID
         )                                                                                     AS batchStatusLookupID
              , billMasterTran.unbilledRevenueGeneralLedgerExportStatusLookupID                AS generalLedgerStatus
              , billMaster.canInvoice                                                          AS canInvoice
              , billMaster.billMasterStatusLookupID
         FROM Bullhorn1.BH_BillableCharge innerCharge
                LEFT JOIN Bullhorn1.View_BillMaster billMaster
                          ON billMaster.billableChargeID = innerCharge.billableChargeID
                LEFT JOIN Bullhorn1.BH_BillMasterTransaction billMasterTran
                          ON billMasterTran.billMasterID = billMaster.billMasterID
                LEFT JOIN Bullhorn1.BH_BillMasterTransaction billMasterReversedBy
                          ON billMasterReversedBy.billMasterID = billMasterTran.billMasterID
                            AND
                             billMasterReversedBy.reversalOfTransactionID = billMasterTran.billMasterTransactionID
                            AND billMasterReversedBy.transactionTypeID = 6
                LEFT JOIN Bullhorn1.View_BillingProfile billProf
                          ON innerCharge.billingProfileID = billProf.billingProfileID
                            AND
                             innerCharge.periodEndDate BETWEEN billProf.viewableStartDate AND billProf.effectiveEndDate
                LEFT JOIN Bullhorn1.View_InvoiceTerm invTerm
                          ON invTerm.InvoiceTermID = billProf.invoiceTermID
                            AND
                             innerCharge.periodEndDate BETWEEN invTerm.viewableStartDate AND invTerm.effectiveEndDate
                LEFT JOIN Bullhorn1.BH_InvoiceStatementLineItem lineItem
                          ON lineItem.invoiceStatementLineItemID = billMasterTran.invoiceStatementLineItemID
                LEFT JOIN Bullhorn1.BH_InvoiceStatement invoice
                          ON lineItem.invoiceStatementID = invoice.invoiceStatementID
       ) innerGrouped
  GROUP BY innerGrouped.billableChargeID
) AS grouped
            ON grouped.billableChargeID = charge.billableChargeID
;
