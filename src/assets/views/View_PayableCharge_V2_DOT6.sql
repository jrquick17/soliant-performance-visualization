SELECT charge.payableChargeID,
       charge.placementID,
       charge.readyToPayOverride,
       charge.periodEndDate,
       charge.description,
       charge.dateAdded,
       charge.dateLastModified,
       grouped.payableChargeStatusLookupID,
       grouped.readyToPay,
       grouped.subtotal,
       grouped.currencyUnitID,
       grouped.transactionStatusID,
       placement.userID AS candidateUserID,
       placement.employeeType,
       grouped.transactionTypeID,
       placement.clientCorporationID,
       placement.jobPostingID,
       charge.generalLedgerSegment1ID,
       charge.generalLedgerSegment2ID,
       charge.generalLedgerSegment3ID,
       charge.generalLedgerSegment4ID,
       charge.generalLedgerSegment5ID,
       grouped.canExport,
       charge.addedByUserID,
       charge.generalLedgerServiceCodeID,
       charge.entryTypeLookupID,
       placement.legalBusinessEntityID,
       charge.externalID,
       placement.payGroup,
       location.state   as locationState,
       department.name  AS department,
       timeAndExpense.timeAndExpenseSource,
       timeAndExpense.timeAndExpenseBranch
FROM Bullhorn1.BH_PayableCharge charge WITH (NOLOCK)
       LEFT JOIN Bullhorn1.BH_Placement placement WITH (NOLOCK)
                 ON charge.placementID = placement.placementID
       LEFT JOIN bullhorn1.View_Location location WITH (NOLOCK)
                 ON location.locationID = placement.locationID
                   AND location.viewableStartDate <= charge.periodEndDate AND
                    charge.periodEndDate <= location.effectiveEndDate
       LEFT JOIN bullhorn1.BH_PlacementTimeAndExpense timeAndExpense WITH (NOLOCK)
                 ON timeAndExpense.timeAndExpenseID = placement.placementTimeAndExpenseID
       LEFT JOIN bullhorn1.BH_Candidate candidate WITH (NOLOCK)
                 ON candidate.userID = placement.userID AND candidate.isPrimaryOwner = 1
       LEFT JOIN bullhorn1.View_UserPrimaryDepartment primaryDepartment WITH (NOLOCK)
                 ON candidate.recruiterUserID = primaryDepartment.userID
       LEFT JOIN bullhorn1.BH_Department department WITH (NOLOCK)
                 ON department.departmentID = primaryDepartment.departmentID
       JOIN
     (
       SELECT innerCharge.payableChargeID,
              CASE
                WHEN COUNT(*) = COUNT(CASE
                                        WHEN transactionExportAttempts.statusPriority = 10
                                          THEN 1 END)
                  THEN 4 --Exported
                WHEN COUNT(CASE WHEN transactionExportAttempts.statusPriority = 20 THEN 1 END) >= 1 OR
                     MIN(paybleChargeExportProcessing.statusID) = 2 -- There are no completed transactions
                  THEN 5 --Processing
                WHEN COUNT(CASE WHEN transactionExportAttempts.statusPriority = 30 THEN 1 END) >=
                     1 -- When all are failed and none are processing
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
                    WHEN payMasterTran.payExportBatchID IS NULL OR transactionExportAttempts.statusPriority = 30
                      THEN 1
                    ELSE 0 END)                    AS canExport
       FROM Bullhorn1.BH_PayableCharge innerCharge WITH (NOLOCK)
              LEFT JOIN Bullhorn1.BH_PayMaster payMaster WITH (NOLOCK)
                        ON payMaster.payableChargeID = innerCharge.payableChargeID
              LEFT JOIN Bullhorn1.BH_PayMasterTransaction payMasterTran WITH (NOLOCK)
                        ON payMasterTran.payMasterID = payMaster.payMasterID
              LEFT JOIN Bullhorn1.BH_TransactionType tranType WITH (NOLOCK)
                        ON payMasterTran.transactionTypeID = tranType.transactionTypeID
              LEFT JOIN bullhorn1.View_PayMasterTransactionExportAttempts transactionExportAttempts
                        ON transactionExportAttempts.payMasterTransactionID = payMasterTran.payMasterTransactionID
              LEFT JOIN (
         SELECT pebpc.payableChargeID,
                MIN(CASE
                      WHEN peb.batchStatusLookupID IN (1, 2)
                        THEN 2
                      ELSE 99 -- Setting to 99 so it's ignored in the MIN above
                  END) AS statusID
         FROM Bullhorn1.BH_PayExportBatchPayableCharge pebpc WITH (NOLOCK)
                INNER JOIN bullhorn1.BH_PayExportBatch peb WITH (NOLOCK)
                           ON peb.payExportBatchID = pebpc.payExportBatchID
         GROUP BY pebpc.payableChargeID
       ) paybleChargeExportProcessing ON paybleChargeExportProcessing.payableChargeID = innerCharge.payableChargeID
       GROUP BY innerCharge.payableChargeID,
                innerCharge.readyToPayOverride
     ) AS grouped
     ON grouped.payableChargeID = charge.payableChargeID
;
