CREATE VIEW View_PayableCharge
AS SELECT
     charge.payableChargeID,
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
     jobOrder.clientCorporationID,
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
     location.state as locationState,
     department.name AS department,
     timeAndExpense.timeAndExpenseSource,
     timeAndExpense.timeAndExpenseBranch
   FROM
     Bullhorn1.BH_PayableCharge charge WITH ( NOLOCK )
       LEFT JOIN Bullhorn1.BH_Placement placement WITH ( NOLOCK )
                 ON charge.placementID = placement.placementID
       LEFT JOIN Bullhorn1.BH_UserContact cand WITH ( NOLOCK )
                 ON placement.userID = cand.userID
       LEFT JOIN Bullhorn1.BH_JobPosting jobOrder WITH ( NOLOCK )
                 ON jobOrder.jobPostingID = placement.jobPostingID
       LEFT JOIN bullhorn1.View_Location location WITH (NOLOCK)
                 ON location.locationID = placement.locationID
                   AND location.viewableStartDate <= charge.periodEndDate AND charge.periodEndDate <= location.effectiveEndDate
       LEFT JOIN bullhorn1.BH_PlacementTimeAndExpense timeAndExpense WITH (NOLOCK)
                 ON timeAndExpense.timeAndExpenseID = placement.placementTimeAndExpenseID
       LEFT JOIN bullhorn1.BH_Candidate candidate WITH (NOLOCK)
                 ON candidate.userID = placement.userID AND candidate.isPrimaryOwner = 1
       LEFT JOIN bullhorn1.View_UserPrimaryDepartment primaryDepartment WITH (NOLOCK)
                 ON candidate.recruiterUserID = primaryDepartment.userID
       LEFT JOIN bullhorn1.BH_Department department WITH (NOLOCK)
                 ON department.departmentID = primaryDepartment.departmentID;
