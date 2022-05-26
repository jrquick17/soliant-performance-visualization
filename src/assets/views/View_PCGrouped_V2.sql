SELECT innerCharge.payableChargeID,
       CASE
         WHEN COUNT(*) = COUNT(CASE
                                 WHEN charge.statusPriority = 10
                                   THEN 1 END)
           THEN 4 --Exported
         WHEN COUNT(CASE WHEN charge.statusPriority = 20 THEN 1 END) >= 1 OR
              MIN(paybleChargeExportProcessing.statusID) = 2 -- There are no completed transactions
           THEN 5 --Processing
         WHEN COUNT(CASE WHEN charge.statusPriority = 30 THEN 1 END) >=
              1 -- When all are failed and none are processing
           AND innerCharge.readyToPayOverride != 1
           THEN 6 --Export Error
         WHEN (innerCharge.readyToPayOverride =
               1) --Payable Charge is marked as ready via override, do not look at transaction statuses
           THEN 2 --Ready To Pay
         WHEN (COUNT(CASE
                       WHEN charge.payMasterTransactionID IS NULL
                         OR charge.statusPriority = 30
                         THEN 1
           END) =
               COUNT(CASE
                       WHEN payMaster.transactionStatusID = 4
                         AND (charge.payMasterTransactionID IS NULL OR charge.statusPriority = 30
                              ) THEN 1
                 END)) --All non-exported pay master records are APPROVED
           THEN 2 --Ready to Pay
         ELSE 1 --Not Ready to Pay
         END                                AS payableChargeStatusLookupID,
       CASE
         WHEN (COUNT(*) = COUNT(CASE
                                  WHEN payMaster.transactionStatusID = 4
                                    THEN 1 END)) --All pay master records are APPROVED
           THEN 2 --Ready to Pay
         ELSE 1 --Not Ready to Pay
         END                                AS readyToPay,
       CASE
         WHEN COUNT(DISTINCT payMasterTran.currencyUnitID) = 1
           THEN SUM(payMasterTran.amount)
         ELSE NULL
         END                                AS subtotal,
       CASE
         WHEN COUNT(DISTINCT payMasterTran.currencyUnitID) = 1
           THEN MIN(payMasterTran.currencyUnitID)
         ELSE NULL
         END                                AS currencyUnitID,
       MIN(payMaster.transactionStatusID)   AS transactionStatusID,
       MIN(payMasterTran.transactionTypeID) AS transactionTypeID,
       MAX(CASE
             WHEN payMasterTran.payExportBatchID IS NULL OR charge.statusPriority = 30
               THEN 1
             ELSE 0 END)                    AS canExport
FROM Bullhorn1.BH_PayableCharge innerCharge WITH (NOLOCK)
       LEFT JOIN Bullhorn1.BH_PayMaster payMaster WITH (NOLOCK)
                 ON payMaster.payableChargeID = innerCharge.payableChargeID
       LEFT JOIN Bullhorn1.BH_PayMasterTransaction payMasterTran WITH (NOLOCK)
                 ON payMasterTran.payMasterID = payMaster.payMasterID
       LEFT JOIN Bullhorn1.BH_TransactionType tranType WITH (NOLOCK)
                 ON payMasterTran.transactionTypeID = tranType.transactionTypeID
       LEFT JOIN Bullhorn1.View_Thing paybleChargeExportProcessing
                 ON paybleChargeExportProcessing.payableChargeID = innerCharge.payableChargeID
GROUP BY innerCharge.payableChargeID,
         innerCharge.readyToPayOverride
