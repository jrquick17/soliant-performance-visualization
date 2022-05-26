SELECT charge.payableChargeID,
       grouped.payableChargeStatusLookupID
FROM Bullhorn1.BH_PayableCharge charge
       JOIN (
  SELECT innerCharge.payableChargeID,
         CASE
           WHEN COUNT(*) = COUNT(CASE
                                   WHEN transactionExportAttempts.statusPriority = 10
                                     THEN 1 END)
             THEN 4 --Exported
           WHEN COUNT(CASE WHEN transactionExportAttempts.statusPriority = 20 THEN 1 END) >= 1 OR
                MIN(paybleChargeExportProcessing.statusID) = 2 -- There are no completed transactions
             THEN 5 --Processing
           WHEN COUNT(CASE WHEN transactionExportAttempts.statusPriority = 30 THEN 1 END) >= 1 -- When all are failed and none are processing
             AND innerCharge.readyToPayOverride != 1
             THEN 6 --Export Error
           WHEN (innerCharge.readyToPayOverride =
                 1) --Payable Charge is marked as ready via override, do not look at transaction statuses
             THEN 2 --Ready To Pay
           WHEN (COUNT(CASE
                         WHEN transactionExportAttempts.payMasterTransactionID IS NULL
                           OR transactionExportAttempts.statusPriority = 30
                           THEN 1
             END) =
                 COUNT(CASE
                         WHEN payMaster.transactionStatusID = 4
                           AND (transactionExportAttempts.payMasterTransactionID IS NULL OR
                                transactionExportAttempts.statusPriority = 30
                                ) THEN 1
                   END)) --All non-exported pay master records are APPROVED
             THEN 2 --Ready to Pay
           ELSE 1 --Not Ready to Pay
           END                                AS payableChargeStatusLookupID
  FROM Bullhorn1.BH_PayableCharge innerCharge
         LEFT JOIN Bullhorn1.BH_PayMaster payMaster
                   ON payMaster.payableChargeID = innerCharge.payableChargeID
         LEFT JOIN Bullhorn1.BH_PayMasterTransaction payMasterTran
                   ON payMasterTran.payMasterID = payMaster.payMasterID
         LEFT JOIN bullhorn1.View_PayMasterTransactionExportAttempts transactionExportAttempts
                   ON transactionExportAttempts.payMasterTransactionID = payMasterTran.payMasterTransactionID
         LEFT JOIN (
    SELECT pebpc.payableChargeID,
           MIN(CASE
                 WHEN peb.batchStatusLookupID IN (1, 2)
                   THEN 2
                 ELSE 99 -- Setting to 99 so it's ignored in the MIN above
             END) AS statusID
    FROM Bullhorn1.BH_PayExportBatchPayableCharge pebpc
           INNER JOIN bullhorn1.BH_PayExportBatch peb
                      ON peb.payExportBatchID = pebpc.payExportBatchID
    GROUP BY pebpc.payableChargeID
  ) paybleChargeExportProcessing ON paybleChargeExportProcessing.payableChargeID = innerCharge.payableChargeID
  GROUP BY innerCharge.payableChargeID,
           innerCharge.readyToPayOverride
) AS grouped
            ON grouped.payableChargeID = charge.payableChargeID
;
