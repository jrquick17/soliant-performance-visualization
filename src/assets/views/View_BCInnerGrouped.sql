SELECT innerCharge.billableChargeID
     , innerCharge.readyToBillOverride
     , billMasterTran.invoiceStatementBatchID
     , billMasterTran.invoiceStatementLineItemID
     , tranType.name
     , invoice.creditOfInvoiceStatementID
     , invoice.isFinalized
     , billMaster.transactionStatusID
     , billMaster.isEligible
     , billMaster.isEligibleOverride
     , invTerm.invoiceApprovedTimecardsRequired
     , billMasterTran.invoiceStatementID
     , billMasterTran.transactionTypeID
     , billMasterTran.needsReview
     , CASE WHEN billMasterReversedBy.transactionTypeID IS NOT NULL THEN 1 ELSE 0 END AS wasUnbilled
     , billMasterTran.currencyUnitID
     , billMasterTran.amount
     , placement.userID
     , billProf.clientCorporationID
     , billProf.billingCorporateUserID
     , billProf.billingClientCorporationID
     , billProf.billingClientUserID
     , billProf.invoiceTermID
     , invTerm.billingScheduleID
     , placement.jobPostingID
     , placement.billingFrequency
     , bcInnerGrouped.batchStatusLookupID
     , billMasterTran.unbilledRevenueGeneralLedgerExportStatusLookupID                AS generalLedgerStatus
     , billMaster.canInvoice                                                          AS canInvoice
     , billMaster.billMasterStatusLookupID
FROM Bullhorn1.BH_BillableCharge innerCharge WITH (NOLOCK)
       LEFT JOIN Bullhorn1.View_BCInvoiceStatementBatchBillableCharge bcInnerGrouped WITH (NOLOCK)
                 ON billMaster.billableChargeID = innerCharge.billableChargeID
       LEFT JOIN Bullhorn1.View_BillMaster billMaster WITH (NOLOCK)
                 ON billMaster.billableChargeID = innerCharge.billableChargeID
       LEFT JOIN Bullhorn1.BH_BillMasterTransaction billMasterTran WITH (NOLOCK)
                 ON billMasterTran.billMasterID = billMaster.billMasterID
       LEFT JOIN Bullhorn1.BH_BillMasterTransaction billMasterReversedBy WITH (NOLOCK)
                 ON billMasterReversedBy.billMasterID = billMasterTran.billMasterID
                   AND
                    billMasterReversedBy.reversalOfTransactionID = billMasterTran.billMasterTransactionID
                   AND billMasterReversedBy.transactionTypeID = 6
       LEFT JOIN Bullhorn1.BH_BillingSyncBatch syncBatch WITH (NOLOCK)
                 ON billMaster.billingSyncBatchID = syncBatch.billingSyncBatchID
       LEFT JOIN Bullhorn1.BH_Placement placement WITH (NOLOCK)
                 ON innerCharge.placementID = placement.placementID
       LEFT JOIN Bullhorn1.View_BillingProfile billProf WITH (NOLOCK)
                 ON innerCharge.billingProfileID = billProf.billingProfileID
                   AND
                    innerCharge.periodEndDate BETWEEN billProf.viewableStartDate AND billProf.effectiveEndDate
       LEFT JOIN Bullhorn1.View_InvoiceTerm invTerm WITH (NOLOCK)
                 ON invTerm.InvoiceTermID = billProf.invoiceTermID
                   AND
                    innerCharge.periodEndDate BETWEEN invTerm.viewableStartDate AND invTerm.effectiveEndDate
       LEFT JOIN Bullhorn1.BH_InvoiceStatementLineItem lineItem WITH (NOLOCK)
                 ON lineItem.invoiceStatementLineItemID = billMasterTran.invoiceStatementLineItemID
       LEFT JOIN Bullhorn1.BH_InvoiceStatement invoice WITH (NOLOCK)
                 ON lineItem.invoiceStatementID = invoice.invoiceStatementID
       LEFT JOIN Bullhorn1.BH_UserContact cand WITH (NOLOCK)
                 ON placement.userID = cand.userID
       LEFT JOIN Bullhorn1.BH_TransactionType tranType WITH (NOLOCK)
                 ON billMasterTran.transactionTypeID = tranType.transactionTypeID
;
