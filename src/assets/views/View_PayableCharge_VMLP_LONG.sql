SELECT charge.payableChargeID,
       charge.placementID,
       charge.readyToPayOverride,
       charge.periodEndDate,
       charge.description,
       charge.dateAdded,
       charge.dateLastModified,
       charge.generalLedgerSegment1ID,
       charge.generalLedgerSegment2ID,
       charge.generalLedgerSegment3ID,
       charge.generalLedgerSegment4ID,
       charge.generalLedgerSegment5ID,
       charge.addedByUserID,
       charge.generalLedgerServiceCodeID,
       charge.entryTypeLookupID,
       charge.externalID,
       charge.timeAndExpenseSource,
       charge.timeAndExpenseBranch,
       charge.department,
       grouped.payableChargeStatusLookupID,
       grouped.readyToPay,
       grouped.subtotal,
       grouped.currencyUnitID,
       grouped.transactionStatusID,
       grouped.transactionTypeID,
       grouped.canExport,
       location.state   as locationState,
       placement.legalBusinessEntityID,
       placement.payGroup,
       placement.userID AS candidateUserID,
       placement.employeeType,
       placement.clientCorporationID,
       placement.jobPostingID
FROM Bullhorn1.BH_PayableCharge charge WITH (NOLOCK)
       LEFT JOIN Bullhorn1.BH_Placement placement WITH (NOLOCK)
                 ON charge.placementID = placement.placementID
       LEFT JOIN bullhorn1.View_Location location WITH (NOLOCK)
                 ON location.locationID = placement.locationID
                   AND location.viewableStartDate <= charge.periodEndDate AND
                    charge.periodEndDate <= location.effectiveEndDate
       JOIN bullhorn1.View_Grouped AS grouped
            ON grouped.payableChargeID = charge.payableChargeID
;
