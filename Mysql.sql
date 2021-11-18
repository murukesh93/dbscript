-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.8-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for ezcloud
CREATE DATABASE IF NOT EXISTS `ezcloud` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `ezcloud`;

-- Dumping structure for procedure ezcloud.savecomment
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `savecomment`(
pcommentId int(11),
pcomment	longtext,
ppostedBy	INT,
ptagBy	longtext,
pinvoiceId INT,
paction VARCHAR(30)
)
BEGIN

IF paction="Add" THEN
   INSERT INTO tblcomments(comment,postDate,postedBy,invoiceId,isDeleted)
   VALUE(pcomment,NOW(),ppostedBy,pinvoiceId,0);
   SET pcommentId= LAST_INSERT_ID();
	
	INSERT INTO tbltageduser(commentId,userId)
SELECT pcommentId,userId FROM tbluser WHERE  find_in_set (userId, ptagBy) AND userId> 0;
	select pcommentId commentId,'Success' message; 
ELSE
    DELETE FROM tbltageduser WHERE commentId=pcommentId;
    INSERT INTO tbltageduser(commentId,userId)
    SELECT pcommentId,userId FROM tbluser WHERE  find_in_set (userId, ptagBy) AND userId> 0;
    UPDATE tblcomments SET COMMENT=pcomment,invoiceId=pinvoiceId WHERE commentId=pcommentId;
	 SELECT pcommentId commentId, 'Success'message; 
END IF;

end//
DELIMITER ;

-- Dumping structure for procedure ezcloud.saveinvoiceline
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `saveinvoiceline`(
pinvoiceLineId	int,
pinvoiceId	INT,
poperatingUnit	varchar(30),
pinvoiceLineNumber	varchar(30),
pinvoiceLineType	varchar(30),
pinvoiceLineAmount	decimal(10,2),
paction VARCHAR(30)
)
BEGIN

IF paction="Add" THEN
   INSERT INTO tblinvoiceline(invoiceId,operatingUnit,invoiceLineNumber,invoiceLineType,invoiceLineAmount)
   VALUE(pinvoiceId,poperatingUnit,pinvoiceLineNumber,pinvoiceLineType,pinvoiceLineAmount);
   SELECT LAST_INSERT_ID() invoiceLineId; 
ELSE
    UPDATE tblinvoiceline SET invoiceId=pinvoiceId,operatingUnit=poperatingUnit,
	 invoiceLineNumber=pinvoiceLineNumber,invoiceLineType=pinvoiceLineType,invoiceLineAmount=pinvoiceLineAmount
	 WHERE invoiceLineId=pinvoiceLineId;
	 SELECT pinvoiceLineId invoiceLineId; 
END IF;

END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spcreateinvoicedetails
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spcreateinvoicedetails`(
pInvoiceNumber	varchar(25),
pSenderEmail	VARCHAR(50),
pDueDate	VARCHAR(20),
pDueAmount	VARCHAR(20),
pTextractJson	TEXT,
pTextTractStatus	BOOLEAN,
pFilePath	VARCHAR(1000),
pOrderNumber VARCHAR(30),
pSuccess BOOLEAN,
pTextractFailed BOOLEAN,
pManualExtractFailed Boolean,
pStatus VARCHAR(25),
pinvoiceType VARCHAR(20),
pName VARCHAR(30),
pPhoneNumber VARCHAR(30),
pCreatedBy INT,
pinvoiceDate DATETIME,
psupplierSite VARCHAR(250),
ptaxNumber VARCHAR(50),
pbankAccount VARCHAR(50),
psortCode VARCHAR(50),
pswift VARCHAR(50),
piban VARCHAR(50),
psupplierAddress VARCHAR(50),
pinvoiceCurrency VARCHAR(30),
pinvoiceAmount DECIMAL(10,2),
ppaidAmount DECIMAL(10,2),
ptaxTotal DECIMAL(10,2),
pinvoiceDescription VARCHAR(500),
preceiverEmail VARCHAR(50)

)
BEGIN

INSERT INTO tblinvoicedetails(invoiceNumber,senderEmail,dueDate,dueAmount,textractJson,textTractStatus,
filepath,createdDate,isDeleted,orderNumber,success,textractFailed,manualExtractFailed,status,invoiceType,name,phoneNumber,
createdBy,invoiceDate,supplierSite,taxNumber,bankAccount,sortCode,swift,iban,supplierAddress,invoiceCurrency,invoiceAmount,paidAmount,
taxTotal,invoiceDescription,receiverEmail)
VALUES(pInvoiceNumber,pSenderEmail,pDueDate,pDueAmount,pTextractJson,pTextTractStatus,
pFilepath,NOW(),0,pOrderNumber,pSuccess,pTextractFailed,pManualExtractFailed,pStatus,pinvoiceType,pName,pPhoneNumber,pCreatedBy,
pinvoiceDate,psupplierSite,ptaxNumber,pbankAccount,psortCode,pswift,piban,psupplierAddress,pinvoiceCurrency,pinvoiceAmount,ppaidAmount,
ptaxTotal,pinvoiceDescription,preceiverEmail); 

SELECT LAST_INSERT_ID()invoiceId; 

UPDATE tblinvoicedetails SET status="Auto Approved" WHERE invoiceId=LAST_INSERT_ID() AND  status="Pending" AND 
dueAmount <= (SELECT autoApproval FROM tblteam WHERE invoiceSenderEmail=pSenderEmail);
 
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spdeletecomment
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spdeletecomment`(pcommentId INT)
BEGIN
 UPDATE  tblcomments set isDeleted=1 WHERE isDeleted=0 AND commentId=pcommentId;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spDeleteInvoice
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteInvoice`(pinvoiceId INT)
BEGIN
 UPDATE  tblinvoicedetails set isDeleted=1 WHERE isDeleted=0 AND invoiceId=pinvoiceId;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spdeleteinvoiceline
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spdeleteinvoiceline`(
  pinvoiceLineId int
)
BEGIN
 DELETE FROM  tblinvoiceline WHERE invoiceLineId=pinvoiceLineId;
 SELECT "Success"message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spDeleteSupplierRequest
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteSupplierRequest`(prequestId INT)
BEGIN
 DELETE FROM tblsupplierrequest WHERE requestId=prequestId;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spDeleteUser
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteUser`(puserId INT,pisActive int)
BEGIN
UPDATE tbluser SET isActive=pisActive WHERE userId=puserId;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spForGetPassword
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spForGetPassword`(pemail VARCHAR(50),pnewPassword VARCHAR(500))
BEGIN
SET @firstName="";
if (SELECT COUNT(userId) FROM tbluser WHERE email=pemail AND isDeleted=0) =0 then
SELECT "Invalid User" message; 
ELSE 
UPDATE tbluser SET password=pnewPassword,isDefaultPassword=1 WHERE email=pemail AND isDeleted=0;
SET @firstName=(SELECT firstName FROM tbluser WHERE password=pnewPassword and email=pemail AND isDeleted=0 LIMIT 1 );
SELECT "Success" message ,@firstName firstName;

END if;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spforgetpasswordforphone
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spforgetpasswordforphone`(pphoneNumber VARCHAR(50),pcountryCode VARCHAR(50),pnewPassword VARCHAR(500))
BEGIN
if (SELECT COUNT(userId) FROM tbluser WHERE phoneNumber=pphoneNumber AND isDeleted=0) =0 then
SELECT "Invalid User" message; 
ELSE 
UPDATE tbluser SET password=pnewPassword,isDefaultPassword=1 WHERE phoneNumber=pphoneNumber AND isDeleted=0;
SELECT "Success" message;
END if;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spgetackemaildetails
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spgetackemaildetails`( pemail VARCHAR(50), prole VARCHAR(50))
BEGIN
if prole="Supplier" then
SELECT tm.companyName,tm.teamId,us.firstName FROM tblteam tm 
INNER JOIN tblteammembers m ON m.teamId=tm.teamId
INNER JOIN tbluser us ON us.userId=m.userId
WHERE invoiceSenderEmail=pemail AND entityType="Supplier" AND us.userRole="Supplier" and us.isDeleted=0 LIMIT 1;

ELSE

SELECT tm.companyName,tm.teamId,us.firstName FROM tblteam tm 
INNER JOIN tblteammembers m ON m.teamId=tm.teamId
INNER JOIN tbluser us ON us.userId=m.userId
WHERE invoiceSenderEmail=pemail AND entityType="Customer" AND us.userRole="Admin" and us.isDeleted=0
ORDER BY us.createdDate asc LIMIT 1;

END if;

END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spgetchatuser
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spgetchatuser`(pteamId INT,pinvoiceId INT)
BEGIN
SELECT us.userId, us.firstName,us.lastName,us.email,us.profileLogo,us.userRole FROM tbluser us INNER JOIN
tblteammembers mb ON mb.userId=us.userId WHERE us.isDeleted=0 AND teamId=pteamId 
UNION ALL
SELECT us.userId, us.firstName,us.lastName,us.email,us.profileLogo,us.userRole FROM tbluser us INNER JOIN
tblteammembers mb ON mb.userId=us.userId WHERE us.userId 
IN(SELECT userId FROM tbluser WHERE email IN(SELECT senderEmail FROM tblinvoicedetails WHERE invoiceId=pinvoiceId));
end//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spgetcomment
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spgetcomment`(pcount int,poffset INT,ppostedBy INT,pinvoiceId INT,
pcomment VARCHAR(50))
BEGIN

SET @SQL = "SELECT * FROM vwgetcomment where 0=0 "; 
SET @sqlCount=" SELECT count(commentId)totalCount FROM vwgetcomment where 0=0 ";
SET @filter="";
 
 if ppostedBy > 0 then
 SET @filter= CONCAT (" and postedBy= " , ppostedBy);
 END if ;
 
 if pinvoiceId > 0 then
 SET @filter= CONCAT (" and invoiceId= " , pinvoiceId);
 END if ;
 
 if pcomment <> "" then
 SET @filter= CONCAT(@filter," and comment  like '%",pcomment,"%'");
 END if ;

 
SET @sqlCount=CONCAT(@sqlCount,@filter);
 
 SET @filter= CONCAT(@filter," order by postDate asc  LIMIT  ",pcount * poffset,",",pcount );

SET @SQL=CONCAT(@SQL,@filter);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlCount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spgetdashboard
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spgetdashboard`(
 pteamId INT,
 psenderEmail VARCHAR(50),
 pyear VARCHAR(20),
 puserId int
)
BEGIN
  DECLARE papprovalAmountTo DECIMAL(10,2); 
  
IF pteamId > 0 THEN
  
  SELECT count(invoiceId)approved FROM vwgetinvoicedetails WHERE status="Approved" AND teamId=pteamId; 
  SELECT count(invoiceId)pending FROM vwgetinvoicedetails where status="Pending" AND teamId=pteamId; 
  SELECT count(status)totalCount,status statusName FROM vwgetinvoicedetails  WHERE teamId=pteamId  and status IS NOT NULL AND invoiceYear =year(NOW()) 
  AND (STATUS="Pending" OR STATUS="Approved" OR  status="Auto Approved" ) GROUP BY STATUS ORDER BY STATUS asc; 
  SELECT sum(invoiceAmount)amount,mntName ,STATUS name FROM vwgetinvoicedetails 
  where invoiceYear =pyear and invoiceAmount is not NULL AND(status="Pending" OR status="Auto Approved" OR status="Approved") AND   teamId=pteamId GROUP BY status,mntName ORDER BY invoiceDate asc;
  SELECT count(invoiceId)autoApproved FROM vwgetinvoicedetails WHERE ( status="Auto Approved") AND teamId=pteamId; 
 
  SELECT sum(invoiceAmount)amount,invoiceYear ,STATUS name FROM vwgetinvoicedetails 
  where invoiceYear =pyear and invoiceAmount is not NULL AND(status="Pending" OR status="Auto Approved" OR status="Approved") AND   teamId=pteamId GROUP BY status,invoiceYear ORDER BY invoiceDate asc;
 
 elseIF psenderEmail <>""  THEN
  
  SELECT count(invoiceId)approved FROM vwgetinvoicedetails WHERE status="Approved" AND senderEmail=psenderEmail 
  AND requestId >0; 
  SELECT count(invoiceId)pending FROM vwgetinvoicedetails where status="Pending" AND senderEmail=psenderEmail AND requestId >0;  
  SELECT count(status)totalCount,status statusName FROM vwgetinvoicedetails  where senderEmail=psenderEmail and status IS NOT NULL AND invoiceYear =year(NOW()) 
  AND (STATUS="Pending" OR STATUS="Approved" OR  status="Auto Approved" ) AND requestId >0 GROUP BY STATUS ORDER BY STATUS asc; 
  SELECT sum(invoiceAmount)amount,mntName ,STATUS name FROM vwgetinvoicedetails 
  where invoiceYear =pyear and invoiceAmount is not NULL AND(status="Pending" OR status="Auto Approved" OR status="Approved") AND   senderEmail=psenderEmail GROUP BY status,mntName ORDER BY invoiceDate asc;
  SELECT count(invoiceId)autoApproved FROM vwgetinvoicedetails WHERE ( status="Auto Approved") AND senderEmail=psenderEmail AND requestId >0; 
 
  SELECT sum(invoiceAmount)amount,invoiceYear ,STATUS name FROM vwgetinvoicedetails 
  where invoiceYear =pyear and invoiceAmount is not NULL AND(status="Pending" OR status="Auto Approved" OR status="Approved") 
  AND   senderEmail=psenderEmail AND requestId >0 GROUP BY status,invoiceYear ORDER BY invoiceDate asc;
  
  ELSEIF  puserId > 0  then  
  
  SELECT approvalAmountTo,tm.teamId INTO 
  papprovalAmountTo,pteamId FROM tbluser us LEFT JOIN tblteammembers tm ON
 tm.userId=us.userId WHERE  us.userId=puserId and isDeleted=0; 

  SELECT count(invoiceId)approved FROM vwgetinvoicedetails WHERE status="Approved" AND teamId=pteamId AND  invoiceAmount <= papprovalAmountTo; 
  SELECT count(invoiceId)pending FROM vwgetinvoicedetails where status="Pending" AND teamId=pteamId AND  invoiceAmount <= papprovalAmountTo; 
  SELECT count(status)totalCount,status statusName FROM vwgetinvoicedetails  WHERE teamId=pteamId  and status IS NOT NULL AND invoiceYear =year(NOW()) 
  AND (STATUS="Pending" OR STATUS="Approved" OR  status="Auto Approved" ) AND  invoiceAmount <= papprovalAmountTo GROUP BY STATUS ORDER BY STATUS asc; 
  SELECT sum(invoiceAmount)amount,mntName ,STATUS name FROM vwgetinvoicedetails 
  where invoiceYear =pyear and invoiceAmount is not NULL AND(status="Pending" OR status="Auto Approved" OR status="Approved") AND   teamId=pteamId AND  invoiceAmount <= papprovalAmountTo GROUP BY status,mntName ORDER BY invoiceDate asc;
  SELECT count(invoiceId)autoApproved FROM vwgetinvoicedetails WHERE ( status="Auto Approved") AND teamId=pteamId; 
 
  SELECT sum(invoiceAmount)amount,invoiceYear ,STATUS name FROM vwgetinvoicedetails 
  where invoiceYear =pyear and invoiceAmount is not NULL AND(status="Pending" OR status="Auto Approved" OR status="Approved") AND   teamId=pteamId AND  invoiceAmount <= papprovalAmountTo GROUP BY status,invoiceYear ORDER BY invoiceDate asc;
  
 
ELSE
   
  SELECT count(invoiceId)approved FROM vwgetinvoicedetails where status="Approved" ; 
  SELECT count(invoiceId)pending FROM vwgetinvoicedetails where status="Pending" ; 
  SELECT count(status)totalCount,status statusName FROM vwgetinvoicedetails where status IS NOT null 
  AND invoiceYear =pyear AND (STATUS="Pending" OR STATUS="Approved" OR  status="Auto Approved" )
  GROUP BY STATUS ORDER BY STATUS asc; 
  
  /*SELECT sum(invoiceAmount)amount,invoiceYear,status name FROM vwgetinvoicedetails 
  where invoiceYear = year(NOW()) and invoiceAmount is not NULL
   AND(status="Pending" OR status="Auto Approved" OR status="Approved")  GROUP BY status,invoiceYear ORDER BY invoiceDate asc;
  */
  
  SELECT sum(invoiceAmount)amount,mntName,status name FROM vwgetinvoicedetails 
  where invoiceYear =pyear  and invoiceAmount is not NULL
   AND(status="Pending" OR status="Auto Approved" OR status="Approved")  GROUP BY status,mntName ORDER BY invoiceDate asc;

  SELECT count(invoiceId)autoApproved FROM vwgetinvoicedetails WHERE ( status="Auto Approved"); 
 
  SELECT sum(invoiceAmount)amount,invoiceYear,status name FROM vwgetinvoicedetails 
  where invoiceYear =pyear  and invoiceAmount is not NULL
   AND(status="Pending" OR status="Auto Approved" OR status="Approved")  GROUP BY status,invoiceYear ORDER BY invoiceDate asc;
 
END IF;

END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetEntityUser
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetEntityUser`( pentityType VARCHAR(50),pemail VARCHAR(50),pcount int,poffset INT,
pteamId int)
BEGIN

SET @SQL = "SELECT * FROM vwGetEntityUser where 0=0 "; 
SET @sqlCount=" SELECT count(email)totalCount FROM vwGetEntityUser where 0=0 ";
SET @filter="";

 if pteamId > 0 then
 SET @filter= CONCAT (" and teamId= " , pteamId);
 END if ;
 
  
 if pentityType <> "" then
 SET @filter= CONCAT(@filter," and entityType = '",pentityType,"'");
 END if ;
 
 if pemail <> "" then
 SET @filter= CONCAT(@filter," and email like '%",pemail,"%'");
 END if ;

SET @sqlCount=CONCAT(@sqlCount,@filter);
 
 SET @filter= CONCAT(@filter," order by email asc  LIMIT  ",pcount * poffset,",",pcount );
SET @SQL=CONCAT(@SQL,@filter);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlCount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetInvoice
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetInvoice`(pteamId INT,papprovalAmountFrom DECIMAL(10,2),
papprovalAmountTo DECIMAL(10,2),pcount int,poffset INT,pstatus VARCHAR(50),pcompanyName VARCHAR(50),pinvoiceNumber VARCHAR(30),
ptotalAmount DECIMAL(10,2),preceiverEmail VARCHAR(50),psenderEmail VARCHAR(50),pdueAmount DECIMAL(10,2),psupplierCompanyName VARCHAR(50),
pname VARCHAR(50),pinvoiceAmount DECIMAL(10,2),psupplierEmail VARCHAR(50))
BEGIN

SET @SQL = "SELECT * FROM vwgetinvoicedetails where 0=0 "; 
SET @sqlCount=" SELECT count(invoiceId)totalCount FROM vwgetinvoicedetails where 0=0 ";
SET @filter="";
 
 if pteamId > 0 then
 SET @filter= CONCAT ( @filter, " and teamId= " , pteamId);
 END if ; 
  
 if papprovalAmountTo <> 0 then
 SET @filter= CONCAT ( @filter, " AND invoiceAmount <=", papprovalAmountTo );
 END if ;
 
 
  if pname <> "" then
 SET @filter= CONCAT(@filter," and name  like '%",pname,"%'");
 END if ;
 
  if pinvoiceNumber <> "" then
 SET @filter= CONCAT(@filter," and invoiceNumber  like '%",pinvoiceNumber,"%'");
 END if ;
 
  if pcompanyName <> "" then
 SET @filter= CONCAT(@filter," and companyName  like '%",pcompanyName,"%'");
 END if ;
 
 if pstatus <> "" then
 SET @filter= CONCAT(@filter," and status = '",pstatus,"'");
 END if ;
 
 if ptotalAmount > 0 then
 SET @filter= CONCAT ( @filter," AND totalAmount =", ptotalAmount );
 END if ;
 

 if papprovalAmountFrom > 0 then
 SET @filter= CONCAT ( @filter, " AND invoiceAmount >=", papprovalAmountFrom );
 END if ;
 
 if preceiverEmail <> "" then
  SET @filter= CONCAT(@filter," and receiverEmail = '",preceiverEmail,"'");
 END if ;
 
  if psenderEmail <> "" then
  SET @filter= CONCAT(@filter," and senderEmail = '",psenderEmail,"'");
  SET @filter= CONCAT(@filter," and requestId > 0 ");
 END if ;
 
  if psupplierCompanyName <> "" then
 SET @filter= CONCAT(@filter," and supplierCompanyName  like '%",psupplierCompanyName,"%'");
 END if ;
 
 
 
  if pdueAmount > 0 then
 SET @filter= CONCAT ( @filter, " AND dueAmount =", pdueAmount );
 END if ;
 
   if pinvoiceAmount > 0 then
 SET @filter= CONCAT ( @filter, " AND invoiceAmount =", pinvoiceAmount );
 END if ;
 
 
 if psupplierEmail <> "" then
  SET @filter= CONCAT(@filter," and senderEmail = '",psupplierEmail,"'"); 
 END if ;
 
 
SET @sqlCount=CONCAT(@sqlCount,@filter);
 
 SET @filter= CONCAT(@filter," order by invoiceId desc  LIMIT  ",pcount * poffset,",",pcount );
SET @SQL=CONCAT(@SQL,@filter);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlCount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetInvoiceDetailById
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetInvoiceDetailById`(pinvoiceId INT,puserId int)
BEGIN
 if (SELECT COUNT(invoiceId) FROM vwgetinvoicedetails WHERE  invoiceId=pinvoiceId)=0 then
 SELECT "No record found" message;
 ELSEif
(SELECT COUNT(invoiceId) FROM vwgetinvoicedetails vw INNER JOIN tbluser us ON us.userId=puserId
LEFT JOIN tblteammembers me ON me.userId=us.userId
LEFT JOIN tblsupplierrequest rq ON rq.supplierEmail=vw.senderEmail AND rq.teamId=vw.teamId AND rq.requestStatus="Accepted"
WHERE  invoiceId=pinvoiceId 
AND (us.userRole="Super Admin" OR (us.userRole="Admin" AND me.teamId=vw.teamId)
OR( us.userRole="Supplier" AND us.email=vw.senderEmail AND rq.requestId >0 ) 
OR (us.userRole="Team Member" AND me.teamId=vw.teamId AND (vw.invoiceAmount IS NULL OR vw.invoiceAmount <= us.approvalAmountTo) ) 
OR (us.userRole="Team Member" AND me.teamId=vw.teamId AND (vw.invoiceAmount IS NULL OR us.approvalAmountTo =-1) ) 
))=0  then

  SELECT "Unauthorized access" message;
  
 else
 
 SELECT *,"Success" message FROM vwgetinvoicedetails WHERE  invoiceId=pinvoiceId;
 
 END if;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetInvoiceDetailByIdApproval
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetInvoiceDetailByIdApproval`(pinvoiceId INT)
BEGIN  
SELECT *   FROM vwgetinvoicedetails WHERE  invoiceId=pinvoiceId; 
 
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetInvoiceDetails
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetInvoiceDetails`()
begin
SELECT * FROM tblinvoicedetails WHERE isDeleted=0 ORDER BY invoiceId DESC LIMIT  1000;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spgetinvoicefieldlist
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spgetinvoicefieldlist`(pteamId INT)
BEGIN

if pteamId=0 then
SELECT * FROM tblinvoicefieldlist WHERE isActive=1 ;
ELSE

SELECT fl.fieldListId,fl.fieldName,fl.moduleName,fl.isActive,IFNULL(ci.customerInvoiceFieldId,0)customerInvoiceFieldId,
 IFNULL(ci.teamId,pteamId)teamId,IFNULL(isRequired,false) isRequired,columnName,IFNULL(isVisible,false) isVisible,
IFNULL(fieldOrder,1) fieldOrder
FROM tblinvoicefieldlist fl 
LEFT JOIN tblcustomerinvoicefield ci ON ci.fieldListId=fl.fieldListId and ci.teamId=pteamId
WHERE fl.isActive=1 ORDER by fieldOrder asc;

END if;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetInvoiceReport
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetInvoiceReport`(pteamId INT,papprovalAmountTo  DECIMAL(10,2),pcount int,poffset INT,
pstatus VARCHAR(50),pinvoiceNumber VARCHAR(30),preceiverEmail VARCHAR(50),
psenderEmail VARCHAR(50),pdueAmount DECIMAL(10,2),psupplierCompanyName VARCHAR(50),pinvoiceAmount DECIMAL(10,2),
pcreatedFromDate VARCHAR(30),pcreatedToDate VARCHAR(30), pdueFromDate VARCHAR(30),pdueToDate VARCHAR(30),
pinvoiceFromDate VARCHAR(30),pinvoiceToDate VARCHAR(30),pApprovedBy INT,pisDuplicate VARCHAR(25),
pis3PercentageRange VARCHAR(25),papprovedByRole VARCHAR(30)
)
BEGIN

SET @SQL = "SELECT * FROM vwGetInvoiceReport where 0=0 "; 
SET @sqlCount=" SELECT count(invoiceId)totalCount FROM vwGetInvoiceReport where 0=0 ";

SET @sqlInvoiceAmount=" SELECT SUM(invoiceAmount)invoiceAmount FROM vwGetInvoiceReport where 0=0 ";
SET @sqlDueAmount=" SELECT SUM(dueAmount)dueAmount FROM vwGetInvoiceReport where 0=0 ";



SET @filter="";
 
 
 if papprovedByRole <> "" then
 SET @filter= CONCAT(@filter," and actionByRole  like '%",papprovedByRole,"%'");
 END if ;
 
 
 if pteamId > 0 then
 SET @filter= CONCAT ( @filter, " and teamId= " , pteamId);
 END if ; 
 
 if pisDuplicate ="true" then
 SET @filter= CONCAT ( @filter, " and isDuplicate=1 " );
 END if ; 
 
 if pis3PercentageRange = "true" then
 SET @filter= CONCAT ( @filter, " and is3PercentageRange=1 " );
 END if ; 
 
  
  if papprovalAmountTo <> 0 then
 SET @filter= CONCAT ( @filter, " AND invoiceAmount <=", papprovalAmountTo );
 END if ;

 if pstatus <> "" then
 SET @filter= CONCAT(@filter," and status = '",pstatus,"'");
 END if ;
 
  if pinvoiceNumber <> "" then
 SET @filter= CONCAT(@filter," and invoiceNumber  like '%",pinvoiceNumber,"%'");
 END if ;
   
 if preceiverEmail <> "" then
  SET @filter= CONCAT(@filter," and receiverEmail = '",preceiverEmail,"'");
 END if ;
 
if psenderEmail <> "" then
  SET @filter= CONCAT(@filter," and senderEmail = '",psenderEmail,"'");
--  SET @filter= CONCAT(@filter," and requestId > 0 ");
 END if ;

 if pdueAmount > 0 then
 SET @filter= CONCAT ( @filter, " AND dueAmount =", pdueAmount );
 END if ;
  
  if psupplierCompanyName <> "" then
 SET @filter= CONCAT(@filter," and supplierCompanyName  like '%",psupplierCompanyName,"%'");
 END if ;

if pinvoiceAmount > 0 then
 SET @filter= CONCAT ( @filter, " AND invoiceAmount =", pinvoiceAmount );
 END if ;
 
 
 if pApprovedBy > 0 then
 SET @filter= CONCAT ( @filter, " and actionBy= " , pApprovedBy);
 END if ; 

 if pcreatedFromDate <> "" then
  SET @filter= CONCAT(@filter," and date(invCreatedDate) >= '",pcreatedFromDate,"'");
 END if ; 
 
 if pcreatedToDate <> "" then
  SET @filter= CONCAT(@filter," and date(invCreatedDate) <= '",pcreatedToDate,"'");
 END if ;  
 
 if pdueFromDate <> "" then
  SET @filter= CONCAT(@filter," and date(dueDate) >= '",pdueFromDate,"'");
 END if ;  
 
 if pdueToDate <> "" then
  SET @filter= CONCAT(@filter," and date(dueDate) <= '",pdueToDate,"'");
 END if ;
 
  if pinvoiceFromDate <> "" then
  SET @filter= CONCAT(@filter," and date(invoiceDate) >= '",pinvoiceFromDate,"'");
 END if ;
 
  if pinvoiceToDate <> "" then
  SET @filter= CONCAT(@filter," and date(invoiceDate) <= '",pinvoiceToDate,"'");
 END if ;  
 
SET @sqlCount=CONCAT(@sqlCount,@filter);
SET @sqlInvoiceAmount=CONCAT(@sqlInvoiceAmount,@filter);
SET @sqlDueAmount=CONCAT(@sqlDueAmount,@filter);

 
SET @filter= CONCAT(@filter," order by invoiceId desc  LIMIT  ",pcount * poffset,",",pcount );
SET @SQL=CONCAT(@SQL,@filter);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlCount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlInvoiceAmount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlDueAmount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetLog
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetLog`()
BEGIN
    SELECT * FROM tbllog   order by logId desc LIMIT 25;
    
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetNextInvoice
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetNextInvoice`(pteamId INT,papprovalAmountFrom DECIMAL(10,2),
papprovalAmountTo DECIMAL(10,2),pcurrentInvoiceId INT,psenderEmail VARCHAR(50))
BEGIN

SET @SQL = "SELECT * FROM vwgetinvoicedetails where 0=0 and status='Pending' "; 
SET @filter="";
SET @minfilter="";
SET @SQLMin= @SQL;

 if pteamId > 0 then
 SET @filter= CONCAT ( @filter, " and teamId= " , pteamId);
 END if ; 
  
 if papprovalAmountTo <> 0 then
 SET @filter= CONCAT ( @filter, " AND invoiceAmount <=", papprovalAmountTo );
 END if ;
 
 if papprovalAmountFrom > 0 then
 SET @filter= CONCAT ( @filter, " AND invoiceAmount >=", papprovalAmountFrom );
 END if ;
 
if psenderEmail <> "" then
  SET @filter= CONCAT(@filter," and senderEmail = '",psenderEmail,"'");
   SET @filter= CONCAT(@filter," and requestId > 0 ");
 END if ;
 
SET @minfilter= @filter;

if pcurrentInvoiceId > 0 then
 SET @filter= CONCAT ( @filter, " and invoiceId > " , pcurrentInvoiceId);
 END if ; 
 
SET @filter= CONCAT(@filter," order by invoiceId asc limit 1 ");
SET @SQL=CONCAT(@SQL,@filter);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

if pcurrentInvoiceId > 0 then
 SET @minfilter= CONCAT ( @minfilter, " and invoiceId < " , pcurrentInvoiceId);
 END if ; 

SET @minfilter= CONCAT(@minfilter," order by invoiceId asc limit 1 ");
SET @SQLMin=CONCAT(@SQLMin,@minfilter);


PREPARE STMT FROM @SQLMin;
EXECUTE STMT;
DEALLOCATE PREPARE STMT;


END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetSupplierRequest
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetSupplierRequest`(pteamId INT,prequestStatus VARCHAR(50),
pcompanyName VARCHAR(50),prequestedName VARCHAR(50),prequestId INT, pcount int,poffset INT,
psupplierEmail  VARCHAR(50),psupplierCompanyName VARCHAR(50))
BEGIN

SET @SQL = "SELECT * FROM vwsupplierrequest where 0=0 "; 
SET @sqlCount=" SELECT count(requestId)totalCount FROM vwsupplierrequest where 0=0 ";
SET @filter="";
 
 if pteamId > 0 then
 SET @filter= CONCAT ( @filter, " and teamId= " , pteamId);
 END if ; 
  
 if prequestStatus <> "" then
 SET @filter= CONCAT(@filter," and requestStatus = '",prequestStatus,"'");
 END if ;
 
 if pcompanyName <> "" then
 SET @filter= CONCAT(@filter," and companyName like '%",pcompanyName,"%'");
 END if ;

 if prequestedName <> "" then
 SET @filter= CONCAT(@filter," and requestedName like '%",prequestedName,"%'");
 END if ;

 if prequestId > 0 then
 SET @filter= CONCAT ( @filter, " and requestId= " , prequestId);
 END if ; 

 if psupplierEmail <> "" then
 SET @filter= CONCAT(@filter," and supplierEmail like '%",psupplierEmail,"%'");
 END if ;
 
  if psupplierCompanyName <> "" then
 SET @filter= CONCAT(@filter," and supplierCompanyName like '%",psupplierCompanyName,"%'");
 END if ;
    
SET @sqlCount=CONCAT(@sqlCount,@filter);
 
 SET @filter= CONCAT(@filter," order by requestId desc  LIMIT  ",pcount * poffset,",",pcount );
SET @SQL=CONCAT(@SQL,@filter);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlCount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetTeamDetailsById
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetTeamDetailsById`(pteamId INT)
BEGIN
SELECT tm.teamId,tm.invoiceSenderEmail,tm.autoApproval,tm.createdDate,tm.teamType,tm.companyLogo,tm.companyName,
tm.planId,tm.createdBy,pl.planName, us.firstName,us.lastName,DATE_FORMAT(expiryDate,'%Y-%m-%d')expiryDate FROM tblteam tm left JOIN tblplan pl on pl.planId=tm.planId
LEFT JOIN tbluser us ON us.userId=tm.createdBy
WHERE teamId=pteamId;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetUser
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetUser`(pteamId INT,pcount int,poffset INT,pemail VARCHAR(50),pcompanyName VARCHAR(50),
pfirstName VARCHAR(50),plastName VARCHAR(50),puserRole VARCHAR(50),pisActive VARCHAR(20))
BEGIN

SET @SQL = "SELECT * FROM vwgetuser where 0=0 "; 
SET @sqlCount=" SELECT count(userId)totalCount FROM vwgetuser where 0=0 ";
SET @filter="";
 
 if pteamId > 0 then
 SET @filter= CONCAT (" and teamId= " , pteamId);
 END if ;

if pemail <> "" then
 SET @filter= CONCAT(@filter," and email  like '%",pemail,"%'");
 END if ;

if pcompanyName <> "" then
 SET @filter= CONCAT(@filter," and companyName  like '%",pcompanyName,"%'");
 END if ;
 
if pfirstName <> "" then
 SET @filter= CONCAT(@filter," and firstName  like '%",pfirstName,"%'");
 END if ;
 
 if plastName <> "" then
 SET @filter= CONCAT(@filter," and lastName  like '%",plastName,"%'");
 END if ;
 
  if puserRole <> "" then
 SET @filter= CONCAT(@filter," and userRole ='",puserRole,"'");
 END if ;
 
  if pisActive <> "" then
 SET @filter= CONCAT(@filter," and isActive ='",pisActive,"'");
 END if ;
 
SET @sqlCount=CONCAT(@sqlCount,@filter);
 
 SET @filter= CONCAT(@filter," order by userId desc  LIMIT  ",pcount * poffset,",",pcount);

SET @SQL=CONCAT(@SQL,@filter);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM @sqlCount;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spGetUserById
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spGetUserById`(puserId INT)
BEGIN
SELECT * FROM vwGetUser  WHERE userId=puserId;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.splockinvoice
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `splockinvoice`(pinvoiceId int,plockedBy INT)
BEGIN

DECLARE lockedUserId INT DEFAULT 0; 
DECLARE lockedUserName  VARCHAR(50); 
DECLARE lockedInvoiceNumber  VARCHAR(50);
DECLARE lockedEmail  VARCHAR(50);
DECLARE accessStatus BOOL;

SET lockedUserId=(SELECT  lockedBy FROM tblinvoicelockdetails WHERE invoiceId=pinvoiceId  LIMIT 1); 

if lockedUserId > 0 then

SELECT concat(us.firstName,us.lastName)userName,us.email,inv.invoiceNumber 
INTO lockedUserName,lockedEmail,lockedInvoiceNumber
FROM  tbluser us 
INNER JOIN tblinvoicedetails inv ON inv.invoiceId=pinvoiceId WHERE us.userId=lockedUserId;

END if;

if lockedUserId > 0 AND lockedUserId =plockedBy then

set accessStatus=TRUE;
UPDATE tblinvoicelockdetails SET lockedDate=NOW() WHERE invoiceId=pinvoiceId AND lockedBy=plockedBy;

ELSEIF lockedUserId > 0 AND lockedUserId <> plockedBy then
set accessStatus=FALSE;

ELSE
set accessStatus=TRUE;
INSERT INTO tblinvoicelockdetails (invoiceId,lockedDate,lockedBy)VALUE(pinvoiceId,NOW(),plockedBy);
END if;

SELECT lockedUserId lockedUserId,lockedUserName lockedUserName, lockedInvoiceNumber lockedInvoiceNumber,
lockedEmail lockedEmail, accessStatus accessStatus;
 
end//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spLogin
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spLogin`(
pemail VARCHAR(50),
ppassword VARCHAR(500)
)
BEGIN
    DECLARE puserId INT DEFAULT 0; 
    DECLARE puserRole  VARCHAR(50); 
    DECLARE papprovalAmountFrom DECIMAL(10,2); 
    DECLARE papprovalAmountTo DECIMAL(10,2); 
    DECLARE pteamId INT DEFAULT 0; 
    DECLARE pAccountExist bool DEFAULT 0; 
    
    set pAccountExist= (case when (SELECT COUNT(userId) FROM tbluser WHERE email=pemail AND isDeleted=0) > 0  then 
	 1 ELSE 0  END);
   
SELECT us.userId,firstName,lastName,email,phoneNumber,approvalAmountFrom,approvalAmountTo,
profileLogo,userRole,"Success"message,isDefaultPassword,tm.teamId, t.companyLogo,isEmailVerified,isPhoneVerified
,countryCode,lastSignIn,lastSignOut,invoiceSenderEmail,t.planId,p.planName,DATE_FORMAT(t.expiryDate,'%Y-%m-%d')expiryDate,
(case when (t.planId=2 AND t.expiryDate >=date(NOW())) OR t.planId<>2 OR t.planId IS null then false ELSE true END )planExpired,us.isActive FROM tbluser us LEFT JOIN tblteammembers tm on
tm.userId=us.userId
LEFT JOIN tblteam t ON t.teamId=tm.teamId
LEFT JOIN tblplan p ON p.planId=t.planId
WHERE email=pemail AND password=ppassword AND isDeleted=0;

SELECT us.userId,approvalAmountFrom,approvalAmountTo,userRole,tm.teamId INTO 
puserId,papprovalAmountFrom,papprovalAmountTo,puserRole,pteamId FROM tbluser us LEFT JOIN tblteammembers tm on
tm.userId=us.userId WHERE email=pemail AND password=ppassword AND isDeleted=0; 

UPDATE tbluser SET lastSignIn=NOW() WHERE userId=puserId;

if puserId > 0 AND puserRole="Team Member" and papprovalAmountTo<>-1 then 
SELECT COUNT(invoiceId)invoiceCount FROM vwgetinvoicedetails WHERE teamId=pteamId AND  invoiceAmount <= papprovalAmountTo;

ELSEIF (puserId > 0 AND puserRole="Admin") OR (puserId > 0 AND puserRole="Team Member" AND papprovalAmountTo=-1) then
SELECT COUNT(invoiceId)invoiceCount FROM vwgetinvoicedetails WHERE teamId=pteamId ;

ELSEIF puserId > 0 AND puserRole="Supplier" then
SELECT COUNT(invoiceId)invoiceCount FROM vwgetinvoicedetails WHERE senderEmail=pemail and requestId > 0  ;


ELSEIf  puserRole="Super Admin" then
SELECT COUNT(invoiceId)invoiceCount FROM vwgetinvoicedetails ;

ELSE 
SELECT 0 invoiceCount ;
END if;

SELECT pAccountExist accountExist;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spReleaseLock
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spReleaseLock`()
BEGIN
delete FROM tblinvoicelockdetails WHERE TIMESTAMPDIFF(MINUTE ,lockedDate,NOW()) >=10;
SELECT "Success"message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spSaveInvoice
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSaveInvoice`( invoiceDetails LONGTEXT )
BEGIN


    DECLARE i INT UNSIGNED DEFAULT 0;
    DECLARE v_count INT UNSIGNED DEFAULT 0 ;
    DECLARE v_current_item LONGTEXT DEFAULT NULL;
    DECLARE att_current_item LONGTEXT DEFAULT NULL;
    DECLARE  attachment LONGTEXT DEFAULT NULL;
 
    
/* DECLARE pInvoiceId INT;
DECLARE pInvoiceNumber varchar(25);
DECLARE pInvoiceDate date;
DECLARE pMessageBody varchar(100); 
DECLARE pAttachment LONGTEXT;
*/

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
SELECT @full_error;
RESIGNAL;

END;
DECLARE exit handler for sqlwarning
BEGIN
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
SELECT @full_error;
RESIGNAL;
END;

START TRANSACTION;
  SET v_count=IFNULL(JSON_LENGTH(invoiceDetails), 0);
   
    WHILE i < v_count DO
     
	      SET v_current_item :=
            JSON_EXTRACT(invoiceDetails, CONCAT('$[', i, ']'));
        
        -- SET @temporal = JSON_EXTRACT(in_array, CONCAT('$[', i, ']'));
        -- SELECT REPLACE(v_current_item,'\\','') into v_current_item;
        -- SELECT REPLACE(v_current_item,'"{','{') into v_current_item;
        -- SELECT REPLACE(v_current_item,'}"','}') into v_current_item;

        SET @invNumber =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.invNumber'));
        SET @attachment =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.attachment'));
        SET @body =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.body'));
        SET @invDate =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.invDate'));
        
        
        INSERT INTO tblInvoice(invoiceNumber,messageBody,invoiceDate,createdDate,isDeleted)
        VALUES(@invNumber,@body,@invDate,NOW(),0); 
        SET @invId=LAST_INSERT_ID(); 
        
        
         SET @att_count=IFNULL(JSON_LENGTH(@attachment), 0); 
         SET @j  = 0; 
		   SET @att_current_item= NULL;
		   
       
         
           WHILE @j < @att_count DO
     
	         SET @att_current_item :=
            JSON_EXTRACT(@attachment, CONCAT('$[', @j, ']'));
            
            SET @filepath = JSON_UNQUOTE(JSON_EXTRACT(@att_current_item, '$.fpath'));
            

            INSERT INTO tblAttachment (invoiceId,filepath,isDeleted)VALUES(@invId,@filepath,0);
            
             SET @j = @j + 1; 
             END WHILE;  
             

        SET i := i + 1;
    END WHILE;
 

   SELECT v_count v_count;
COMMIT;

END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spSaveInvoiceDetails
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSaveInvoiceDetails`(
pInvoiceNumber	varchar(25),
pSenderEmail	VARCHAR(50),
pDueDate	VARCHAR(20),
pDueAmount	VARCHAR(20),
pTextractJson	TEXT,
pTextTractStatus	BOOLEAN,
pFilePath	VARCHAR(1000),
pOrderNumber VARCHAR(25),
pSuccess BOOLEAN,
pTextractFailed BOOLEAN,
pManualExtractFailed BOOLEAN,
pinvoiceType VARCHAR(50),
preceiverEmail VARCHAR(50),
pstatus VARCHAR(50),
pname VARCHAR(50),
pphoneNumber VARCHAR(50),
pinvoiceDate VARCHAR(50),pinvoiceDescription VARCHAR(500),pdocumentType VARCHAR(50),
pinvoiceAmount  DECIMAL(10,2),ptaxTotal DECIMAL(10,2),pinvoiceCurrency VARCHAR(50),
pimageFilePath varchar(1000),
pextractEngineFailed bool

)
BEGIN

INSERT INTO tblinvoicedetails(invoiceNumber,senderEmail,dueDate,dueAmount,textractJson,textTractStatus,
filepath,createdDate,isDeleted,orderNumber,success,textractFailed,manualExtractFailed,status,invoiceType,receiverEmail,
invoiceNumberTR,dueDateTR,dueAmountTR,orderNumberTR,invoiceDateTR,nameTR,
phoneNumberTR,supplierSiteTR,taxNumberTR,bankAccountTR,sortCodeTR,swiftTR,ibanTR,supplierAddressTR,invoiceCurrencyTR,
invoiceAmountTR,paidAmountTR,taxTotalTR,invoiceDescriptionTR,invoiceStatus,invoicePOStatus,supplierStatus,totalAmountTR,
name,phoneNumber,invoiceDate,invoiceDescription,documentType,invoiceAmount,taxTotal,invoiceCurrency,
documentTypeTR,imageFilePath,extractEngineFailed)
VALUES(pInvoiceNumber,pSenderEmail,pDueDate,pDueAmount,pTextractJson,pTextTractStatus,
pFilepath,NOW(),0,pOrderNumber,pSuccess,pTextractFailed,pManualExtractFailed,pstatus,pinvoiceType,preceiverEmail,
"Extract","Extract","Extract","Extract","Extract","Extract","Extract","Extract","Extract",
"Extract","Extract","Extract","Extract","Extract","Extract","Extract","Extract","Extract","Extract",
"Not Verified","Not Verified","Not Verified","Extract",
pname,pphoneNumber,pinvoiceDate,pinvoiceDescription,pdocumentType,pinvoiceAmount,ptaxTotal,pinvoiceCurrency,
"Extract",pimageFilePath,pextractEngineFailed); 

SELECT LAST_INSERT_ID()invoiceId; 
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spsaveinvoicelineitems
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spsaveinvoicelineitems`(pinvoicelineitems longtext,pfilePath VARCHAR(1000) )
BEGIN
BEGIN 
    DECLARE i INT UNSIGNED DEFAULT 0;
    DECLARE v_count INT UNSIGNED DEFAULT 0 ;
    DECLARE v_current_item LONGTEXT DEFAULT NULL; 
    DECLARE poperatingUnit VARCHAR(50) ;
    DECLARE pinvoiceLineNumber VARCHAR(50) ;
    DECLARE pinvoiceLineType VARCHAR(50) ;
    DECLARE pinvoiceLineAmount DECIMAL(15,2) UNSIGNED DEFAULT 0 ;
    DECLARE pinvoiceLineId INT UNSIGNED DEFAULT 0;
    DECLARE pinvoiceId INT UNSIGNED DEFAULT 0;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
SELECT @full_error;
RESIGNAL;

END;
DECLARE exit handler for sqlwarning
BEGIN
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
SELECT @full_error;
RESIGNAL;
END;

START TRANSACTION;
  SET pinvoiceId= (SELECT invoiceId FROM tblinvoicedetails WHERE filePath=pfilePath AND isDeleted=0 LIMIT 1);
  if(pinvoiceId >0 ) then
  SET v_count=IFNULL(JSON_LENGTH(pinvoicelineitems), 0);
   DELETE FROM tblinvoiceline WHERE invoiceId=pinvoiceId;
    WHILE i < v_count DO
     
	      SET v_current_item :=
            JSON_EXTRACT(pinvoicelineitems, CONCAT('$[', i, ']'));  
       SET poperatingUnit =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.operatingUnit'));
       SET pinvoiceLineNumber =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.invoiceLineNumber'));
       SET pinvoiceLineType =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.invoiceLineType'));
       SET pinvoiceLineAmount =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.invoiceLineAmount'));
        
        SET pinvoiceLineId= ( select min(tab1.invoiceLineId)+1 as missingId from tblinvoiceline as tab1
        left join tblinvoiceline as tab2 on tab2.invoiceLineId=tab1.invoiceLineId+1 where tab2.invoiceLineId is null);
        
      INSERT INTO tblinvoiceline(invoiceLineId,invoiceId,operatingUnit,invoiceLineNumber,invoiceLineType,invoiceLineAmount)values
      (pinvoiceLineId,pinvoiceId,poperatingUnit,pinvoiceLineNumber,pinvoiceLineType,pinvoiceLineAmount);
      
        SET i := i + 1;
    END WHILE;
    
    SELECT v_count v_count,"Success" message;
 ELSE
  SELECT v_count v_count ,"filePath not found" message;
 END if;

    
   
   
COMMIT;
END;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spsaveinvoicemandatoryfields
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spsaveinvoicemandatoryfields`(pfieldList longtext,pteamId int )
BEGIN
BEGIN 
    DECLARE i INT UNSIGNED DEFAULT 0;
    DECLARE v_count INT UNSIGNED DEFAULT 0 ;
    DECLARE v_current_item LONGTEXT DEFAULT NULL;
    DECLARE pcustomerInvoiceFieldId INT UNSIGNED DEFAULT 0 ;
    DECLARE pisRequired INT UNSIGNED DEFAULT 0 ;
    DECLARE pisVisible INT UNSIGNED DEFAULT 0 ;
    DECLARE pfieldListId INT UNSIGNED DEFAULT 0 ;
    DECLARE pfieldOrder INT UNSIGNED DEFAULT 0 ;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
SELECT @full_error;
RESIGNAL;

END;
DECLARE exit handler for sqlwarning
BEGIN
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
SELECT @full_error;
RESIGNAL;
END;

START TRANSACTION;
  SET v_count=IFNULL(JSON_LENGTH(pfieldList), 0);
   
    WHILE i < v_count DO
     
	      SET v_current_item :=
            JSON_EXTRACT(pfieldList, CONCAT('$[', i, ']')); 
       SET pfieldListId = JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.fieldListId'));
       SET pcustomerInvoiceFieldId =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.customerInvoiceFieldId'));
       SET pisRequired =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.isRequired'));
       SET pisVisible =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.isVisible'));
       SET pfieldOrder =  JSON_UNQUOTE(JSON_EXTRACT(v_current_item, '$.fieldOrder'));
        
      if(pcustomerInvoiceFieldId =0 AND (SELECT COUNT(customerInvoiceFieldId) FROM tblcustomerinvoicefield 
		WHERE fieldListId=pfieldListId AND teamId=pteamId  )=0) then
      INSERT INTO tblcustomerinvoicefield(fieldListId,teamId,isRequired,isVisible,fieldOrder)
      VALUES(pfieldListId,pteamId,pisRequired,pisVisible,pfieldOrder);
      else
      UPDATE tblcustomerinvoicefield SET isRequired=pisRequired,isVisible=pisVisible,fieldOrder=pfieldOrder WHERE 
      customerInvoiceFieldId=pcustomerInvoiceFieldId;
      end if;
      
        SET i := i + 1;
    END WHILE;
 

   SELECT v_count v_count;
COMMIT;
END;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spSaveLog
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSaveLog`(
pfunctionName	varchar(50),
pfunctionData	TEXT	
)
BEGIN
    INSERT INTO tbllog(functionName,functionData,createdDate)VALUES(pfunctionName,pfunctionData,NOW()); 
    SELECT "Success"message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spsaveotp
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spsaveotp`(
potpType	varchar(20),
potpValue	varchar(10),
potpTo	varchar(50),
pcountryCode VARCHAR(10)
)
BEGIN
  
  if potpType ="Phone" then
  if (SELECT COUNT(userId) FROM tbluser WHERE phoneNumber=potpTo AND isDeleted=0)>0 then
  INSERT INTO tblotp (otpType,otpValue,otpTo,countryCode,createdDate,isVerified)VALUES
  (potpType,potpValue,potpTo,pcountryCode,NOW() + INTERVAL 30 MINUTE,0);
  SELECT "Success" message;
  else
   SELECT "Invalid Phone number" message;
  END if;
  
   END if;
  
  
  if potpType ="Email" then
  if (SELECT COUNT(userId) FROM tbluser WHERE email=potpTo AND isDeleted=0 )>0 then
  INSERT INTO tblotp (otpType,otpValue,otpTo,createdDate,isVerified)VALUES
  (potpType,potpValue,potpTo,NOW() + INTERVAL 30 MINUTE,0);
  SELECT "Success" message;
  else
   SELECT "Invalid Email" message;
  END if;
  
   END if;
  
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spSaveUser
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSaveUser`(
puserId	INT,
pfirstName	varchar(50),
plastName	varchar(50),
pemail	varchar(50),
ppassword	varchar(500),
pphoneNumber	varchar(50),
papprovalAmountFrom	decimal(10,2),
papprovalAmountTo	decimal(10,2),
pprofileLogo	varchar(1000),
pcreatedBy	INT,
puserRole	varchar(25),
pAction VARCHAR(25),
pinvoiceSenderEmail VARCHAR(50),
pteamType VARCHAR(50),
pcompanyLogo VARCHAR(1000),
pcompanyName VARCHAR(100),
pplanId INT,
pisDefaultPassword BOOL,
pisEmailVerified BOOL,
phashKey VARCHAR(50),
pcountryCode VARCHAR(10),
pentityType VARCHAR(25),
pexpiryDate VARCHAR(25)
)
BEGIN
DECLARE emailCount INT DEFAULT 0;
DECLARE phoneCount INT DEFAULT 0;
DECLARE phoneUserId INT DEFAULT 0;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @TEXT);
SELECT @full_error;
RESIGNAL;
END;
DECLARE exit handler for sqlwarning
 BEGIN
 ROLLBACK;
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
SELECT @full_error;
RESIGNAL;
END;

START TRANSACTION;

SET @createdByName=(SELECT concat(firstName,' ',lastName) FROM tbluser WHERE userId=pcreatedBy LIMIT 1 );

if pAction= "Add" then
/* add user start */
set emailCount=(SELECT COUNT(userId) FROM tbluser WHERE email=pemail AND isdeleted=0);
set phoneCount=(SELECT COUNT(userId) FROM tbluser WHERE phoneNumber=pphoneNumber AND isdeleted=0 AND phoneNumber  IS NOT NULL AND phoneNumber<>""  );

if (emailCount=0 AND phoneCount=0) then
INSERT INTO tbluser(firstName,lastName,email,password,phoneNumber,approvalAmountFrom,approvalAmountTo,profileLogo,createdBy,userRole,
createdDate,isDeleted,isDefaultPassword,isEmailVerified,hashKey,countryCode,isPhoneVerified)
VALUES(pfirstName,plastName,pemail,ppassword,pphoneNumber,papprovalAmountFrom,papprovalAmountTo,pprofileLogo,pcreatedBy,puserRole,
NOW(),0,pisDefaultPassword,pisEmailVerified,phashKey,pcountryCode,0); 

SET puserId= (select LAST_INSERT_ID());
SET @teamId= (SELECT  tm.teamId FROM tblteam tb INNER JOIN tblteammembers tm ON tm.userId= pcreatedBy  LIMIT 1 );

-- create team
if puserRole="Admin" OR puserRole="Supplier" then
INSERT INTO tblteam (invoiceSenderEmail,autoApproval,createdDate,teamType,companyLogo,companyName,planId,createdBy,
entityType,expiryDate)
VALUES(pinvoiceSenderEmail,0,NOW(),pteamType,pcompanyLogo,pcompanyName,pplanId,pcreatedBy,pentityType,pexpiryDate);
SET @teamId= (select LAST_INSERT_ID());
END if;

-- create team member
if puserRole="Admin" OR puserRole="Team Member" OR puserRole="Supplier"  then
INSERT INTO tblteammembers (teamId,userId)VALUES(@teamId,puserId);
END if;


SELECT puserId userId, "Success" message,@createdByName createdByName; 

ELSE

if phoneCount >0 then
SELECT 0 userId,"Phone number is already linked to an existing account" message;
ELSE
SELECT 0 userId,"Email already exists" message;
END if;


END if;
-- add user End
ELSE

SET phoneCount=(SELECT count(userId) FROM tbluser WHERE phoneNumber=pphoneNumber and userId<>puserId AND phoneNumber  IS NOT NULL AND phoneNumber<>"" AND isdeleted=0);

-- update section 
if phoneCount=0 then

UPDATE tbluser SET firstName= (case when pfirstName="" OR pfirstName=NULL then firstName ELSE pfirstName END),
lastName= (case when plastName="" OR plastName=NULL then lastName ELSE plastName END),
phoneNumber=pphoneNumber,
approvalAmountTo=papprovalAmountTo,
profileLogo=(case when pprofileLogo="" OR pprofileLogo=NULL then profileLogo ELSE pprofileLogo END),
countryCode=pcountryCode
WHERE userId=puserId;
SELECT puserId userId,"Success" message; 

ELSE
SELECT puserId userId,"Phone number is already linked to an existing account" message; 
END if;

-- update end
END if;
 
COMMIT;   
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spselectinvoiceline
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spselectinvoiceline`(
 pinvoiceId INT,
 pinvoiceLineId int
)
BEGIN
if pinvoiceId >0 then
 SELECT * FROM tblinvoiceline WHERE invoiceId=pinvoiceId ORDER BY invoiceLineNumber ASC ;
 else
  SELECT * FROM tblinvoiceline WHERE invoiceLineId=pinvoiceLineId;
end if;
  
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spSendSupplierRequest
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSendSupplierRequest`(
pteamId	INT,
psupplierEmail	varchar(50),
prequestedBy int
)
begin

DECLARE puserRole  VARCHAR(50);
set puserRole=(SELECT userRole FROM tbluser WHERE email=psupplierEmail AND isDeleted=0);

if (SELECT COUNT(requestId) FROM tblsupplierrequest WHERE teamId=pteamId AND supplierEmail=psupplierEmail
AND isDeleted=0) > 0 then
SELECT "You have already sent an invite to this email address" message;

ELSEIF puserRole IS NOT NULL and puserRole <>"Supplier" then
SELECT CONCAT("User already in ",puserRole," role") message;
ELSE
INSERT INTO tblsupplierrequest (teamId,supplierEmail,requestStatus,requestDate,isDeleted,requestedBy)VALUES
(pteamId,psupplierEmail,"Pending",NOW(),0,prequestedBy);
SELECT "Success" message,(SELECT CONCAT(firstName,' ',lastName) FROM tbluser WHERE userId=prequestedBy)userName,
(SELECT companyName FROM tblteam WHERE teamId=pteamId)companyName;
END if;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spSignOut
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSignOut`(
puserId int
)
BEGIN

UPDATE tbluser SET lastSignOut=NOW() WHERE userId=puserId;
  SELECT "Success" message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spunlockinvoice
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spunlockinvoice`(pinvoiceId int,plockedBy INT)
BEGIN 
DECLARE lockedUserId INT DEFAULT 0; 

SET lockedUserId=(SELECT  lockedBy FROM tblinvoicelockdetails WHERE invoiceId=pinvoiceId AND lockedBy=plockedBy LIMIT 1); 

if lockedUserId > 0  then
DELETE FROM tblinvoicelockdetails WHERE invoiceId=pinvoiceId AND lockedBy=plockedBy;
SELECT "Success" message; 
ELSE
SELECT "Invalid Record" message; 
END if;

end//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spupdateinvoice
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spupdateinvoice`(
pInvoiceNumber	varchar(25),
pSenderEmail	VARCHAR(50),
pDueDate	VARCHAR(20),
pDueAmount	VARCHAR(20),
pTextractJson	TEXT,
pTextTractStatus	BOOLEAN,
pFilePath	VARCHAR(1000),
pOrderNumber VARCHAR(25),
pSuccess BOOLEAN,
pTextractFailed BOOLEAN,
pManualExtractFailed BOOLEAN,
pStatus VARCHAR(30),
pinvoiceId INT,
pname VARCHAR(50),
pphoneNumber VARCHAR(50),
pinvoiceDate VARCHAR(50),
preceiverEmail VARCHAR(50),

pinvoiceAmount	DECIMAL(10,2),
ptaxTotal	DECIMAL(10,2),
pinvoiceCurrency VARCHAR(20),
pdocumentType VARCHAR(25),
pinvoiceDescription	varchar(500),
pimageFilePath varchar(1000),
pextractEngineFailed bool
																								
)
BEGIN
If  pinvoiceId >0 then

 update tblinvoicedetails set 
 invoiceNumber= (case when pInvoiceNumber="" OR pInvoiceNumber=NULL then invoiceNumber ELSE pInvoiceNumber END),
 dueDate= (case when pDueDate="" OR pDueDate=NULL then dueDate ELSE pDueDate END),
 dueAmount= (case when pDueAmount="" OR pDueAmount=NULL then dueAmount ELSE pDueAmount END),
 textractJson= (case when pTextractJson="" OR pTextractJson=NULL then textractJson ELSE pTextractJson END),
 textTractStatus= (case when pTextTractStatus="" OR pTextTractStatus=NULL then textTractStatus ELSE pTextTractStatus END),
 orderNumber= (case when pOrderNumber="" OR pOrderNumber=NULL then orderNumber ELSE pOrderNumber END),
 success= (case when pSuccess="" OR pSuccess=NULL then success ELSE pSuccess END),
 textractFailed= (case when pTextractFailed="" OR pTextractFailed=NULL then textractFailed ELSE pTextractFailed END),
 manualExtractFailed= (case when pManualExtractFailed="" OR pManualExtractFailed=NULL then manualExtractFailed ELSE pManualExtractFailed END),
 status= (case when pStatus="" OR pStatus=NULL then status ELSE pStatus END),
 filePath= (case when pFilePath="" OR pFilePath=NULL then filePath ELSE pFilePath END),
 invoiceDate= (case when pinvoiceDate="" OR pinvoiceDate=NULL then invoiceDate ELSE pinvoiceDate END),
 phoneNumber= (case when pphoneNumber="" OR pphoneNumber=NULL then phoneNumber ELSE pphoneNumber END),
 name= (case when pname="" OR pname=NULL then name ELSE pname END),
 invoiceNumberTR="Extract",dueDateTR="Extract",dueAmountTR="Extract",orderNumberTR="Extract",invoiceDateTR="Extract"
 ,nameTR="Extract",phoneNumberTR="Extract",supplierSiteTR="Extract",taxNumberTR="Extract",bankAccountTR="Extract",
 sortCodeTR="Extract",swiftTR="Extract",ibanTR="Extract",supplierAddressTR="Extract",invoiceCurrencyTR="Extract",
invoiceAmountTR="Extract",paidAmountTR="Extract",taxTotalTR="Extract",invoiceDescriptionTR="Extract",
invoiceStatus="Not Verified",invoicePOStatus="Not Verified",supplierStatus="Not Verified",
supplierSiteTR="Extract",
invoiceAmount	=pinvoiceAmount,taxTotal=ptaxTotal,invoiceCurrency=pinvoiceCurrency,documentType=pdocumentType,
documentTypeTR="Extract",
imageFilePath=pimageFilePath,
extractEngineFailed=pextractEngineFailed																							
WHERE invoiceId=pinvoiceId;
 SELECT pinvoiceId invoiceId;
 else
 
 update tblinvoicedetails set 
 invoiceNumber= (case when pInvoiceNumber="" OR pInvoiceNumber=NULL then invoiceNumber ELSE pInvoiceNumber END),
 dueDate= (case when pDueDate="" OR pDueDate=NULL then dueDate ELSE pDueDate END),
 dueAmount= (case when pDueAmount="" OR pDueAmount=NULL then dueAmount ELSE pDueAmount END),
 textractJson= (case when pTextractJson="" OR pTextractJson=NULL then textractJson ELSE pTextractJson END),
 textTractStatus= (case when pTextTractStatus="" OR pTextTractStatus=NULL then textTractStatus ELSE pTextTractStatus END),
 orderNumber= (case when pOrderNumber="" OR pOrderNumber=NULL then orderNumber ELSE pOrderNumber END),
 success= (case when pSuccess="" OR pSuccess=NULL then success ELSE pSuccess END),
 textractFailed= (case when pTextractFailed="" OR pTextractFailed=NULL then textractFailed ELSE pTextractFailed END),
 manualExtractFailed= (case when pManualExtractFailed="" OR pManualExtractFailed=NULL then manualExtractFailed ELSE pManualExtractFailed END),
 status= (case when pStatus="" OR pStatus=NULL then status ELSE pStatus END),
 invoiceNumberTR="Extract",dueDateTR="Extract",dueAmountTR="Extract",orderNumberTR="Extract",invoiceDateTR="Extract",
 name= (case when pname="" OR pname=NULL then name ELSE pname END),
  invoiceDate= (case when pinvoiceDate="" OR pinvoiceDate=NULL then invoiceDate ELSE pinvoiceDate END),
 nameTR="Extract",phoneNumberTR="Extract",supplierSiteTR="Extract",taxNumberTR="Extract",bankAccountTR="Extract",
 sortCodeTR="Extract",swiftTR="Extract",ibanTR="Extract",supplierAddressTR="Extract",invoiceCurrencyTR="Extract",
invoiceAmountTR="Extract",paidAmountTR="Extract",taxTotalTR="Extract",invoiceDescriptionTR="Extract",
invoiceStatus="Not Verified",invoicePOStatus="Not Verified",supplierStatus="Not Verified",
supplierSiteTR="Extract",
invoiceAmount	=pinvoiceAmount,taxTotal=ptaxTotal,invoiceCurrency=pinvoiceCurrency,documentType=pdocumentType,
documentTypeTR="Extract",
imageFilePath=pimageFilePath,
extractEngineFailed=pextractEngineFailed																										
WHERE filePath=pFilePath;

 SELECT  invoiceId from tblinvoicedetails WHERE filePath=pFilePath LIMIT 1;
 
END if;

END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spupdateinvoicedetails
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spupdateinvoicedetails`(
pInvoiceId INT,pInvoiceNumber varchar(25),pSenderEmail VARCHAR(50),
pDueDate VARCHAR(20),pDueAmount VARCHAR(20),pTextractJson TEXT,pTextTractStatus BOOLEAN,pFilePath VARCHAR(1000),
pOrderNumber VARCHAR(30),pSuccess BOOLEAN,pTextractFailed BOOLEAN,pManualExtractFailed Boolean,pStatus VARCHAR(25),
pinvoiceType VARCHAR(20),pName VARCHAR(30),pPhoneNumber VARCHAR(30),pinvoiceDate VARCHAR(30),psupplierSite VARCHAR(250),
ptaxNumber VARCHAR(50),pbankAccount VARCHAR(50),psortCode VARCHAR(50),pswift VARCHAR(50),piban VARCHAR(50),
psupplierAddress VARCHAR(50),pinvoiceCurrency VARCHAR(30),pinvoiceAmount DECIMAL(10,2),ppaidAmount DECIMAL(10,2),
ptaxTotal DECIMAL(10,2),pinvoiceDescription VARCHAR(500),preceiverEmail VARCHAR(50),
ptotalAmount DECIMAL(10,2),pdocumentType VARCHAR(50),pupdateBy int
)
BEGIN

update tblinvoicedetails SET
invoiceNumberTR= (case when pInvoiceNumber != invoiceNumber then "Manual" when (invoiceNumber is null and pInvoiceNumber is not null) then "Manual" ELSE invoiceNumberTR END),
dueDateTR=(case when pDueDate != dueDate then "Manual" when (dueDate is null and pDueDate is not null) then "Manual" ELSE dueDateTR END),
dueAmountTR=(case when pDueAmount != dueAmount then "Manual" when (dueAmount is null and pDueAmount is not null) then "Manual" else dueAmountTR END),
orderNumberTR=(case when pOrderNumber != orderNumber then "Manual" when (orderNumber is null and pOrderNumber is not null) then "Manual" ELSE orderNumberTR END),
invoiceDateTR=(case when pinvoiceDate != invoiceDate then "Manual" when (invoiceDate is null and pinvoiceDate is not null) then "Manual" else invoiceDateTR END),
phoneNumberTR=(case when pPhoneNumber != phoneNumber then "Manual" when (phoneNumber is null and pPhoneNumber is not null) then "Manual" ELSE phoneNumberTR END),
supplierSiteTR=(case when psupplierSite != supplierSite then "Manual" when (supplierSite is null and psupplierSite is not null) then "Manual" ELSE supplierSiteTR END),
taxNumberTR=(case when ptaxNumber != taxNumber then "Manual" when (taxNumber is null and ptaxNumber is not null) then "Manual" ELSE taxNumberTR END),
bankAccountTR=(case when pbankAccount != bankAccount then "Manual" when (bankAccount is null and pbankAccount is not null) then "Manual" ELSE bankAccountTR END),
sortCodeTR=(case when psortCode != sortCode then "Manual" when (sortCode is null and psortCode is not null) then "Manual" ELSE sortCodeTR END),
swiftTR=(case when pswift != swift then "Manual" when (swift is null and pswift is not null) then "Manual" ELSE swiftTR END),
ibanTR=(case when piban != iban then "Manual" when (iban is null and piban is not null) then "Manual" ELSE ibanTR END),
supplierAddressTR=(case when psupplierAddress != supplierAddress then "Manual" when (supplierAddress is null and psupplierAddress is not null) then "Manual" ELSE supplierAddressTR END),
invoiceCurrencyTR=(case when pinvoiceCurrency != invoiceCurrency then "Manual" when (invoiceCurrency is null and pinvoiceCurrency is not null) then "Manual" ELSE invoiceCurrencyTR END),
invoiceAmountTR=(case when pinvoiceAmount != invoiceAmount then "Manual" when (invoiceAmount is null and pinvoiceAmount is not null) then "Manual" ELSE invoiceAmountTR END),
paidAmountTR=(case when ppaidAmount != paidAmount then "Manual" when (paidAmount is null and ppaidAmount is not null) then "Manual" ELSE paidAmountTR END),
taxTotalTR=(case when ptaxTotal != taxTotal then "Manual" when (taxTotal is null and ptaxTotal is not null) then "Manual" ELSE taxTotalTR END),
invoiceDescriptionTR=(case when pinvoiceDescription != invoiceDescription then "Manual" when (invoiceDescription is null and pinvoiceDescription is not null) then "Manual" ELSE invoiceDescriptionTR END),
totalAmountTR=(case when ptotalAmount != totalAmount then "Manual" when (totalAmount is null and ptotalAmount is not null) then "Manual" ELSE totalAmountTR END),
documentTypeTR=(case when pdocumentType != documentType then "Manual" when (documentType is null and pdocumentType is not null) then "Manual" ELSE documentTypeTR END)

WHERE invoiceId=pInvoiceId;

update tblinvoicedetails SET
nameTR=(case when pName<> name then "Manual" ELSE nameTR END)
WHERE invoiceId=pInvoiceId;

update tblinvoicedetails SET
invoiceNumber= (case when pinvoiceNumber="" OR pinvoiceNumber=NULL then invoiceNumber ELSE pinvoiceNumber END),
senderEmail=(case when pSenderEmail="" OR pSenderEmail=NULL then senderEmail ELSE pSenderEmail END),
dueDate=pDueDate,
dueAmount=pdueAmount,
textractJson=(case when pTextractJson="" OR pTextractJson=NULL then textractJson ELSE pTextractJson END),
textTractStatus=(case when pTextTractStatus="" OR pTextTractStatus=NULL then textTractStatus ELSE pTextTractStatus END),
filepath=pFilePath,
orderNumber=pOrderNumber,
success=(case when pSuccess="" OR pSuccess=NULL then success ELSE pSuccess END),
textractFailed=(case when pTextractFailed="" OR pTextractFailed=NULL then textractFailed ELSE pTextractFailed END),
manualExtractFailed=(case when pManualExtractFailed="" OR pManualExtractFailed=NULL then manualExtractFailed ELSE pManualExtractFailed END),
status=(case when PStatus="" OR PStatus=NULL then status ELSE PStatus END),
invoiceType=pInvoiceType,
name=pName,
phoneNumber=pPhoneNumber,
invoiceDate=pinvoiceDate,
supplierSite=(case when psupplierSite="" OR psupplierSite=NULL then supplierSite ELSE psupplierSite END),
taxNumber=ptaxNumber,
bankAccount=(case when pbankAccount="" OR pbankAccount=NULL then bankAccount ELSE pbankAccount END),
sortCode=(case when psortCode="" OR psortCode=NULL then sortCode ELSE psortCode END),
swift=pswift,
iban=(case when piban="" OR piban=NULL then iban ELSE piban END),
supplierAddress=(case when psupplierAddress="" OR psupplierAddress=NULL then supplierAddress ELSE psupplierAddress END),
invoiceCurrency=(case when pinvoiceCurrency="" OR pinvoiceCurrency=NULL then invoiceCurrency ELSE pinvoiceCurrency END),
invoiceAmount=pinvoiceAmount,
paidAmount=ppaidAmount,
taxTotal=ptaxTotal,
invoiceDescription=pinvoiceDescription,
receiverEmail=(case when preceiverEmail ="" OR preceiverEmail=NULL then receiverEmail ELSE preceiverEmail END),
totalAmount=ptotalAmount,
documentType =pdocumentType 
WHERE invoiceId=pInvoiceId;

if(pupdateBy >0)then 
INSERT INTO tblinvoicelog (invoiceId,comment,actionBy,actionDate)VALUES(pinvoiceId,"Edit",pupdateBy,NOW());
END if;

DELETE FROM tblinvoicelockdetails WHERE invoiceId=pinvoiceId;
SELECT pInvoiceId invoiceId;

END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spUpdateInvoiceStatus
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateInvoiceStatus`(pinvoiceId INT,pactionBy INT,pstatus	varchar(25))
BEGIN
UPDATE tblinvoicedetails SET STATUS=pstatus,actionBy=pactionBy,actionDate=NOW() WHERE invoiceId=pinvoiceId;
DELETE FROM tblinvoicelockdetails WHERE invoiceId=pinvoiceId;
INSERT INTO tblinvoicelog (invoiceId,comment,actionBy,actionDate)VALUES(pinvoiceId,pstatus,pactionBy,NOW());
SELECT "Success" message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spUpdateInvoiceValidationStatus
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateInvoiceValidationStatus`(
pinvoiceStatus VARCHAR(25),
pinvoicePOStatus VARCHAR(25),
psupplierStatus VARCHAR(25),
pvalidationResponse VARCHAR(1000),
pinvoiceId INT,
pfilepath VARCHAR(1000)
)
BEGIN
if pinvoiceId> 0 then
UPDATE tblinvoicedetails SET invoiceStatus=pinvoiceStatus,invoicePOStatus=pinvoicePOStatus,supplierStatus=psupplierStatus,
validationResponse=pvalidationResponse,validationRequestDate=NOW() WHERE invoiceId=pinvoiceId;

ELSE
UPDATE tblinvoicedetails SET invoiceStatus=pinvoiceStatus,invoicePOStatus=pinvoicePOStatus,supplierStatus=psupplierStatus,
validationResponse=pvalidationResponse,validationRequestDate=NOW() WHERE filepath=pfilepath;

END if;
SELECT "Success" message;
end//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spUpdatePassword
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdatePassword`(pemail VARCHAR(50),poldpassword VARCHAR(500),pnewPassword VARCHAR(500))
BEGIN
SET @firstName="";
if (SELECT COUNT(userId) FROM tbluser WHERE email=pemail AND isDeleted=0) =0 then
SELECT "Invalid User" message;

ELSEIF (SELECT COUNT(userId) FROM tbluser WHERE email=pemail AND isDeleted=0 AND PASSWORD=poldpassword) =0 then
SELECT "Incorrect Current Password" message;

ELSE 
UPDATE tbluser SET password=pnewPassword,isDefaultPassword=0 WHERE email=pemail AND isDeleted=0 AND password=poldpassword;
SET @firstName=(SELECT firstName FROM tbluser WHERE password=pnewPassword and email=pemail AND isDeleted=0 LIMIT 1 );
SELECT "Success" message ,@firstName firstName;

END if;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spUpdateSupplierDetails
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateSupplierDetails`(
psupplierAddress	varchar(500),																								
psupplierAddress2	varchar(250),																								
pcity	varchar(50),																								
pstate	varchar(50),																								
ppostalCode	varchar(25),																								
pcountry	varchar(25),																								
psupplierId	varchar(25),
psupplierSite	varchar(250),
pinvoiceId INT,
pfilePath VARCHAR(1000),
ptaxNumber VARCHAR(50),
pbankAccount VARCHAR(50),
pswift VARCHAR(50),
psortCode VARCHAR(50),
piban VARCHAR(50)																																															
)
BEGIN
if pinvoiceId > 0 then

UPDATE tblinvoicedetails SET supplierAddress=psupplierAddress,supplierAddress2=psupplierAddress2,city=pcity,
state=pstate,postalCode=ppostalCode,country=pcountry,supplierId=psupplierId,supplierSite=psupplierSite,
taxNumber=ptaxNumber,bankAccount=pbankAccount,swift=pswift,sortCode=psortCode,iban=piban
WHERE invoiceId=pinvoiceId; 

ELSE 
UPDATE tblinvoicedetails SET supplierAddress=psupplierAddress,supplierAddress2=psupplierAddress2,city=pcity,
state=pstate,postalCode=ppostalCode,country=pcountry,supplierId=psupplierId,supplierSite=psupplierSite,
taxNumber=ptaxNumber,bankAccount=pbankAccount,swift=pswift,sortCode=psortCode,iban=piban
WHERE filePath=pfilePath;

END if;
SELECT "Success" message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spUpdateSupplierStatus
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateSupplierStatus`(
prequestId	INT,
prequestStatus	varchar(50)
)
begin
UPDATE tblsupplierrequest SET  requestStatus=prequestStatus WHERE requestId=prequestId;
SELECT "Success" message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spUpdateTeam
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateTeam`(pteamId INT,pautoApproval DECIMAL (10,2),pinvoiceSenderEmail VARCHAR(50),
pcompanyLogo VARCHAR(1000),pcompanyName VARCHAR(100))
BEGIN
UPDATE tblteam SET
autoApproval=pautoApproval,
companyLogo= (case when pcompanyLogo="" OR pcompanyLogo=NULL then companyLogo ELSE pcompanyLogo END),
companyName= (case when pcompanyName="" OR pcompanyName=NULL then companyName ELSE pcompanyName END)

WHERE teamId=pteamId;
SELECT "Success" message;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spverifycustomeremail
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spverifycustomeremail`(
pemail VARCHAR(50),
phashKey VARCHAR(50)
)
BEGIN

if (SELECT count(userId) FROM tbluser WHERE email=pemail AND hashKey=phashKey AND isDeleted=0 > 0) then
UPDATE tbluser SET isEmailVerified=1,hashKey=NULL WHERE email=pemail AND hashKey=phashKey AND isDeleted=0;
SELECT "Success"message;

elseif (SELECT count(userId) FROM tbluser WHERE email=pemail AND isEmailVerified=1 AND isDeleted=0 > 0) then
SELECT "Email already verified"message;

ELSE
SELECT "Invalid request"message;

END if;
END//
DELIMITER ;

-- Dumping structure for procedure ezcloud.spverifyotp
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `spverifyotp`(
potpType	varchar(20),
potpValue	varchar(10),
potpTo	varchar(50),
pcountryCode VARCHAR(10)
)
BEGIN
  
  if potpType ="Phone" then
  if (SELECT COUNT(otpId) FROM tblotp WHERE otpTo=potpTo AND isVerified=0 AND otpType=potpType  )>0 then
  UPDATE tbluser SET isPhoneVerified=1 WHERE phoneNumber=potpTo AND isDeleted=0;
  UPDATE tblotp SET isVerified=1 WHERE otpTo=potpTo AND isVerified=0 AND otpType=potpType;
  SELECT "Success" message;
  else
   SELECT "Invalid OTP" message;
  END if;
  
   END if;
  
  
  if potpType ="Email" then
  if (SELECT COUNT(otpId) FROM tblotp WHERE otpTo=potpTo AND isVerified=0 AND otpType=potpType  )>0 then
  UPDATE tbluser SET isEmailVerified=1 WHERE email=potpTo AND isDeleted=0;
  UPDATE tblotp SET isVerified=1 WHERE otpTo=potTo AND isVerified=0 AND otpType=potpType;
  SELECT "Success" message;
  else
   SELECT "Invalid OTP" message;
  END if;
  
   END if;
  
END//
DELIMITER ;

-- Dumping structure for table ezcloud.tblattachment
CREATE TABLE IF NOT EXISTS `tblattachment` (
  `attachmentId` int(11) NOT NULL AUTO_INCREMENT,
  `invoiceId` int(11) DEFAULT NULL,
  `filepath` varchar(1000) DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`attachmentId`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblattachment: ~2 rows (approximately)
/*!40000 ALTER TABLE `tblattachment` DISABLE KEYS */;
INSERT IGNORE INTO `tblattachment` (`attachmentId`, `invoiceId`, `filepath`, `isDeleted`) VALUES
	(19, 13, 'inv#123.pdf', 0),
	(20, 13, 'inv#123_1.pdf', 0);
/*!40000 ALTER TABLE `tblattachment` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblcomments
CREATE TABLE IF NOT EXISTS `tblcomments` (
  `commentId` int(11) NOT NULL AUTO_INCREMENT,
  `comment` longtext DEFAULT NULL,
  `postDate` datetime DEFAULT NULL,
  `postedBy` int(11) DEFAULT NULL,
  `invoiceId` int(11) DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`commentId`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblcomments: ~4 rows (approximately)
/*!40000 ALTER TABLE `tblcomments` DISABLE KEYS */;
INSERT IGNORE INTO `tblcomments` (`commentId`, `comment`, `postDate`, `postedBy`, `invoiceId`, `isDeleted`) VALUES
	(1, 'Hi guys,Pleae reply my message', '2021-07-19 13:29:02', 55, 78, 1),
	(2, 'Hi team, Why till in pending status?', '2021-07-19 13:31:09', 55, 79, 0),
	(3, 'Hi All', '2021-09-01 12:24:06', 54, 79, 0),
	(4, 'Good Afternoon', '2021-09-01 12:24:37', 54, 10, 0);
/*!40000 ALTER TABLE `tblcomments` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblcustomerinvoicefield
CREATE TABLE IF NOT EXISTS `tblcustomerinvoicefield` (
  `customerInvoiceFieldId` int(11) NOT NULL AUTO_INCREMENT,
  `fieldListId` int(11) DEFAULT NULL,
  `teamId` int(11) DEFAULT NULL,
  `isRequired` tinyint(1) DEFAULT NULL,
  `isVisible` tinyint(1) DEFAULT NULL,
  `fieldOrder` int(11) DEFAULT NULL,
  PRIMARY KEY (`customerInvoiceFieldId`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblcustomerinvoicefield: ~6 rows (approximately)
/*!40000 ALTER TABLE `tblcustomerinvoicefield` DISABLE KEYS */;
INSERT IGNORE INTO `tblcustomerinvoicefield` (`customerInvoiceFieldId`, `fieldListId`, `teamId`, `isRequired`, `isVisible`, `fieldOrder`) VALUES
	(7, 4, 1, 1, 1, 2),
	(13, 3, 1, 1, 1, 1),
	(17, 5, 1, 1, 0, 4),
	(21, 11, 1, 1, 1, NULL),
	(46, 2, 1, 1, 1, 1),
	(47, 1, 1, 1, 1, 3);
/*!40000 ALTER TABLE `tblcustomerinvoicefield` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblinvoice
CREATE TABLE IF NOT EXISTS `tblinvoice` (
  `invoiceId` int(11) NOT NULL AUTO_INCREMENT,
  `invoiceNumber` varchar(25) DEFAULT NULL,
  `invoiceDate` date DEFAULT NULL,
  `messageBody` text DEFAULT NULL,
  `createdDate` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`invoiceId`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblinvoice: ~2 rows (approximately)
/*!40000 ALTER TABLE `tblinvoice` DISABLE KEYS */;
INSERT IGNORE INTO `tblinvoice` (`invoiceId`, `invoiceNumber`, `invoiceDate`, `messageBody`, `createdDate`, `isDeleted`) VALUES
	(13, '#123', '2020-08-11', 'data', '2020-08-19 16:15:34', 0),
	(14, '#124', '2020-08-11', 'data', '2020-08-19 16:15:34', 0);
/*!40000 ALTER TABLE `tblinvoice` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblinvoicedetails
CREATE TABLE IF NOT EXISTS `tblinvoicedetails` (
  `invoiceId` int(11) NOT NULL AUTO_INCREMENT,
  `invoiceNumber` varchar(25) DEFAULT NULL,
  `senderEmail` varchar(50) DEFAULT NULL,
  `dueDate` datetime DEFAULT NULL,
  `dueAmount` varchar(20) DEFAULT NULL,
  `textractJson` text DEFAULT NULL,
  `textTractStatus` tinyint(1) DEFAULT NULL,
  `filePath` varchar(1000) DEFAULT NULL,
  `createdDate` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT NULL,
  `orderNumber` varchar(25) DEFAULT NULL,
  `success` tinyint(4) DEFAULT NULL,
  `textractFailed` tinyint(4) DEFAULT NULL,
  `manualExtractFailed` tinyint(4) DEFAULT NULL,
  `status` varchar(25) DEFAULT NULL,
  `invoiceType` varchar(25) DEFAULT NULL,
  `actionBy` int(11) DEFAULT NULL,
  `actionDate` datetime DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `phoneNumber` varchar(30) DEFAULT NULL,
  `createdBy` int(11) DEFAULT NULL,
  `invoiceDate` datetime DEFAULT NULL,
  `supplierSite` varchar(250) DEFAULT NULL,
  `taxNumber` varchar(50) DEFAULT NULL,
  `bankAccount` varchar(50) DEFAULT NULL,
  `sortCode` varchar(50) DEFAULT NULL,
  `swift` varchar(50) DEFAULT NULL,
  `iban` varchar(50) DEFAULT NULL,
  `supplierAddress` varchar(500) DEFAULT NULL,
  `invoiceCurrency` varchar(10) DEFAULT NULL,
  `invoiceAmount` decimal(17,2) DEFAULT NULL,
  `paidAmount` decimal(17,2) DEFAULT NULL,
  `taxTotal` decimal(17,2) DEFAULT NULL,
  `invoiceDescription` varchar(500) DEFAULT NULL,
  `receiverEmail` varchar(50) DEFAULT NULL,
  `invoiceNumberTR` varchar(20) DEFAULT NULL,
  `dueDateTR` varchar(20) DEFAULT NULL,
  `dueAmountTR` varchar(20) DEFAULT NULL,
  `orderNumberTR` varchar(20) DEFAULT NULL,
  `invoiceDateTR` varchar(20) DEFAULT NULL,
  `nameTR` varchar(20) DEFAULT NULL,
  `phoneNumberTR` varchar(20) DEFAULT NULL,
  `supplierSiteTR` varchar(20) DEFAULT NULL,
  `taxNumberTR` varchar(20) DEFAULT NULL,
  `bankAccountTR` varchar(20) DEFAULT NULL,
  `sortCodeTR` varchar(20) DEFAULT NULL,
  `swiftTR` varchar(20) DEFAULT NULL,
  `ibanTR` varchar(20) DEFAULT NULL,
  `supplierAddressTR` varchar(20) DEFAULT NULL,
  `invoiceCurrencyTR` varchar(20) DEFAULT NULL,
  `invoiceAmountTR` varchar(20) DEFAULT NULL,
  `paidAmountTR` varchar(20) DEFAULT NULL,
  `taxTotalTR` varchar(20) DEFAULT NULL,
  `invoiceDescriptionTR` varchar(20) DEFAULT NULL,
  `invoiceStatus` varchar(20) DEFAULT NULL,
  `invoicePOStatus` varchar(20) DEFAULT NULL,
  `supplierStatus` varchar(20) DEFAULT NULL,
  `validationResponse` varchar(1000) DEFAULT NULL,
  `validationRequestDate` datetime DEFAULT NULL,
  `totalAmount` decimal(17,2) DEFAULT NULL,
  `totalAmountTR` varchar(20) DEFAULT NULL,
  `supplierAddress2` varchar(250) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `postalCode` varchar(25) DEFAULT NULL,
  `country` varchar(25) DEFAULT NULL,
  `supplierId` varchar(25) DEFAULT NULL,
  `documentType` varchar(25) DEFAULT NULL,
  `documentTypeTR` varchar(25) DEFAULT NULL,
  `imageFilePath` varchar(1000) DEFAULT NULL,
  `extractEngineFailed` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`invoiceId`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblinvoicedetails: ~78 rows (approximately)
/*!40000 ALTER TABLE `tblinvoicedetails` DISABLE KEYS */;
INSERT IGNORE INTO `tblinvoicedetails` (`invoiceId`, `invoiceNumber`, `senderEmail`, `dueDate`, `dueAmount`, `textractJson`, `textTractStatus`, `filePath`, `createdDate`, `isDeleted`, `orderNumber`, `success`, `textractFailed`, `manualExtractFailed`, `status`, `invoiceType`, `actionBy`, `actionDate`, `name`, `phoneNumber`, `createdBy`, `invoiceDate`, `supplierSite`, `taxNumber`, `bankAccount`, `sortCode`, `swift`, `iban`, `supplierAddress`, `invoiceCurrency`, `invoiceAmount`, `paidAmount`, `taxTotal`, `invoiceDescription`, `receiverEmail`, `invoiceNumberTR`, `dueDateTR`, `dueAmountTR`, `orderNumberTR`, `invoiceDateTR`, `nameTR`, `phoneNumberTR`, `supplierSiteTR`, `taxNumberTR`, `bankAccountTR`, `sortCodeTR`, `swiftTR`, `ibanTR`, `supplierAddressTR`, `invoiceCurrencyTR`, `invoiceAmountTR`, `paidAmountTR`, `taxTotalTR`, `invoiceDescriptionTR`, `invoiceStatus`, `invoicePOStatus`, `supplierStatus`, `validationResponse`, `validationRequestDate`, `totalAmount`, `totalAmountTR`, `supplierAddress2`, `city`, `state`, `postalCode`, `country`, `supplierId`, `documentType`, `documentTypeTR`, `imageFilePath`, `extractEngineFailed`) VALUES
	(10, '302 0033677', 'murukeshs@apptomate.co', '2021-06-01 11:43:57', '78750', 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1622463698288pdf-textracted.json', NULL, 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1622463698288.pdf', '2020-09-11 15:40:47', 0, '341742', 1, 1, NULL, 'Approved', 'Manual', 1, '2021-06-01 11:44:19', 'Corning Tropel Corporation', '+91 78789 89899', NULL, '2020-08-24 00:00:00', '60 O\'Connor Roa', '', '914032-0122', '736198273', '', '', '60 O\'Connor Road', 'USD', 78750.00, 50.00, 10.00, 'invoice', 'swathit@apptomate.co', 'Manual', 'Extract', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Extract', 'Manual', 'Manual', 'Manual', 'Manual', 'Valid', 'Valid', 'Valid', '{"data":[{"Invoice":"302 0033677","Suppliername":"Corning Tropel Corporation","PoNumber":"341742","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Valid","validateSupplierStatus":"Valid"}]}', '2021-05-31 19:33:27', NULL, 'Extract', '60 O\'Connor Road', 'Fairport', 'NY', '14450', 'US', '48', 'INVOICE', 'Manual', NULL, NULL),
	(11, '302 0033961', 'chitras@apptomate.co', NULL, '5670', 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1623149762592pdf-textracted.json', NULL, 'https://inbox-ezcloud123.s3.amazonaws.com/apptomate/chitras_apptomate/1623149762592.pdf', '2020-09-11 15:41:23', 0, '346644', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'Corning Tropel Corporation', NULL, NULL, '2020-10-12 00:00:00', '60 O\'Connor Roa', '', '914032-0122', '736198273', '', '', '60 O\'Connor Road', 'USD', 5670.00, NULL, NULL, NULL, 'swathit@apptomate.co', 'Manual', 'Extract', 'Manual', 'Manual', 'Manual', 'Manual', 'Extract', 'Extract', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Extract', 'Manual', 'Manual', 'Extract', 'Extract', 'Extract', 'Valid', 'Valid', 'Valid', '{"data":[{"Invoice":"302 0033961","Suppliername":"Corning Tropel Corporation","PoNumber":"346644","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Valid","validateSupplierStatus":"Valid"}]}', '2021-06-08 16:36:44', NULL, 'Extract', '60 O\'Connor Road', 'Fairport', 'NY', '14450', 'US', '48', 'INVOICE', 'Extract', NULL, NULL),
	(12, '77473', 'ram1@gmil.com', '2020-05-21 00:00:00', '23', '', 1, 'test.pdf', '2020-09-16 12:56:23', 0, '47463', 1, 1, 1, 'Approved', 'Manual', 55, NULL, 'murukesh', '84838494933', NULL, '2020-02-22 00:00:00', '132, My Street,', '333332', '232332', '23322', 'swi332', '333342', '132, My Street,USA', '$', 100.22, 50.22, 11.00, 'des', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Not Verified', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"77473","Suppliername":"shawn.hummer","PoNumber":"47463","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-05 13:43:42', 111.22, 'Extract', '', 'LAUREL', 'MD', '20723', 'US', '18', NULL, NULL, NULL, NULL),
	(13, '77473', 'murukeshs@apptomate.co', '2020-05-21 00:00:00', '23', '', 1, 'test.pdf', '2020-09-16 12:57:20', 0, '47463', 1, 1, 1, 'Approved', NULL, 55, NULL, NULL, NULL, NULL, NULL, '132, My Street,', NULL, NULL, NULL, NULL, NULL, '132, My Street,USA', NULL, 300.00, 20.00, 0.00, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Not Verified', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"77473","Suppliername":"shawn.hummer","PoNumber":"47463","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-05 13:43:42', 300.00, 'Extract', '', 'LAUREL', 'MD', '20723', 'US', '18', NULL, NULL, NULL, NULL),
	(14, '77473', 'murukeshs@apptomate.co', '2020-05-21 00:00:00', '23', '', 1, 'test.pdf', '2020-09-16 12:57:42', 0, '47463', 1, 1, 1, 'Pending', NULL, 55, NULL, NULL, NULL, NULL, NULL, '132, My Street,', NULL, NULL, NULL, NULL, NULL, '132, My Street,USA', NULL, 400.00, 30.00, 0.00, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Not Verified', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"77473","Suppliername":"shawn.hummer","PoNumber":"47463","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-05 13:43:42', 400.00, 'Extract', '', 'LAUREL', 'MD', '20723', 'US', '18', NULL, NULL, NULL, NULL),
	(15, '77473', 'murukeshs@apptomate.co', '2020-05-21 00:00:00', '23', '', 1, 'test.pdf', '2020-09-16 13:05:14', 0, '47463', 1, 1, 1, 'Pending', NULL, 55, NULL, NULL, NULL, NULL, NULL, '132, My Street,', NULL, NULL, NULL, NULL, NULL, '132, My Street,USA', NULL, 200.00, 50.00, 0.00, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Not Verified', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"77473","Suppliername":"shawn.hummer","PoNumber":"47463","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-05 13:43:42', 200.00, 'Extract', '', 'LAUREL', 'MD', '20723', 'US', '18', NULL, NULL, NULL, NULL),
	(16, '388382', 'murukeshs@apptomate.co', '2021-03-15 00:00:00', '48', 'testpath1.pdf', 1, 'testpath1.pdf', '2020-10-16 15:13:09', 0, '8484', 1, 1, 1, 'Pending', 'PO', 55, NULL, 'Advanced Engineering & EDM,Inc', '8870240610', 5, '2021-03-15 00:00:00', '13007 KIRKHAM', '786987345', '89765678543', '', '', '', '13007', 'USD', 388.44, 60.00, 388.44, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"388382","Suppliername":"Advanced Engineering & EDM,Inc","PoNumber":"8484","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-15 12:50:51', 500.00, 'Extract', 'KIRKHAM WAY', 'POWAY', 'CA', '92064', 'US', '21', 'Invoice', 'Extract', NULL, NULL),
	(17, 'Inv17', 'murukeshs@apptomate.co', '2020-11-11 00:00:00', '20', '{}', 1, '17.pdf', '2020-10-16 15:19:47', 0, 'O17', 1, 1, 1, 'Approved', 'PO', NULL, NULL, 'Apptomate Digital', '8667749365', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Success', 'Success', NULL, NULL, NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(18, '388382', 'murukeshs@apptomate.co', '2021-03-15 00:00:00', '48', 'testpath1.pdf', 1, 'testpath1.pdf', '2020-10-16 15:26:31', 0, '8484', 1, 1, 1, 'Pending', 'PO', NULL, NULL, 'Advanced Engineering & EDM,Inc', '8870240610', 5, '2021-03-15 00:00:00', '13007 KIRKHAM', '786987345', '89765678543', '', '', '', '13007', 'USD', 388.44, 70.00, 388.44, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"388382","Suppliername":"Advanced Engineering & EDM,Inc","PoNumber":"8484","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-15 12:50:51', 800.00, 'Extract', 'KIRKHAM WAY', 'POWAY', 'CA', '92064', 'US', '21', 'Invoice', 'Extract', NULL, NULL),
	(19, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2020-11-03 15:21:16', 0, '252133', 1, 1, NULL, 'Pending', 'Non-PO', NULL, NULL, 'shawn.hummr', '', 5, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(20, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2020-11-03 15:21:57', 0, '252133', 1, 1, NULL, 'Pending', 'Non-PO', NULL, NULL, 'shawn.hummr', '', 5, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', 100.00, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(21, '160133', 'murukeshs@apptomate.co1', NULL, NULL, '', 1, '', '2020-11-03 15:35:18', 0, '252133', 1, 1, NULL, 'Pending', 'Non-PO', NULL, NULL, 'shawn.hummr', '', 5, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co1', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(22, 'inv456', 'apptomate.co', '2020-12-25 00:00:00', '200', '', 1, 'path.pdf', '2020-12-16 13:16:17', 0, 'ord123', 1, 1, 1, 'Approved', 'Manual', NULL, NULL, 'murukesh kumar', '8870240610', 5, '2020-12-21 00:00:00', 'apptomate.com', 'tax1233', 'b1234', 'srt45', 'swft1233', 'iba123', 'Dindigul', '$', 30.00, 10.00, 10.50, 'Descri', 'apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Success', 'Success', NULL, NULL, 40.50, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(23, 'inv4545', 'string', '0000-00-00 00:00:00', 'string', 'string', 1, 'inv4544.pdf', '2020-12-23 15:45:28', 0, '1234', 1, 1, 1, 'Approved', 'string', NULL, NULL, 'string', 'string', 0, '0000-00-00 00:00:00', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 0.00, 0.00, 0.00, 'string', 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Success', 'Success', NULL, NULL, 0.00, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(26, '160133', 'ram1@gmil.com', NULL, NULL, '', 1, '', '2021-02-05 15:25:16', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '8870240610', 24, NULL, '', '', '', '', '', '', '', 'string', NULL, 10.00, NULL, 'desc', 'ram1@gmil.com', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', 500.00, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(27, 'string', 'ram1@gmil.com', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-05 18:09:10', 0, 'string', 1, 1, NULL, 'Auto Approved', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(28, '160133', 'ram1@gmil.com', NULL, NULL, '', 1, '', '2021-02-17 12:39:54', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(29, 'inv9091', 'smith@apptomate.co', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-17 12:57:23', 0, 'string', 1, 1, 1, 'string', 'string', NULL, NULL, 'string', 'string', 0, '0000-00-00 00:00:00', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 0.00, 0.00, 0.00, 'string', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', 0.00, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(30, 'string', 'string', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-18 23:59:15', 0, 'string', 1, 1, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(31, 'string', 'string', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-19 00:03:07', 0, 'string', 1, 1, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(32, 'string', 'string', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-19 00:04:35', 0, 'string', 1, 1, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(33, 'string', 'string', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-19 00:05:08', 0, 'string', 1, 1, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(34, 'string', 'string', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-19 12:49:40', 0, 'string', 1, 1, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(35, 'string', 'string', '0000-00-00 00:00:00', 'string', 'string', 1, 'string', '2021-02-19 13:05:40', 0, 'string', 1, 1, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(36, 'string', NULL, NULL, NULL, NULL, NULL, NULL, '2021-02-19 13:06:04', 0, NULL, NULL, NULL, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Success', 'Success', NULL, NULL, NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(37, 'string', NULL, NULL, NULL, NULL, NULL, NULL, '2021-02-19 13:09:28', 0, NULL, NULL, NULL, NULL, 'Re-processing', 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Success', 'Success', NULL, NULL, NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(38, 'inv092', 'string', '2020-02-21 00:00:00', '56', 'string', 1, 'string', '2021-02-19 14:29:34', 0, '85855', 1, 1, 1, 'Pending', 'Extract', NULL, NULL, 'string', '8738833202', NULL, '2021-02-21 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"string","PoNumber":"string","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-03 13:00:34', NULL, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(39, '160133', 'ram1@gmail.com', NULL, NULL, '', 1, '', '2021-02-21 07:36:35', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '84838494933', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, 50.22, NULL, 'des', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', 111.22, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(40, '160133', 'ram1@gmail.com', NULL, NULL, '', 1, '', '2021-02-21 11:24:00', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(41, '160133', 'ram1@gmail.com', NULL, NULL, '', 1, '', '2021-02-21 11:26:36', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(42, '160133', 'ram1@gmail.com', NULL, NULL, '', 1, '', '2021-02-21 11:34:11', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(43, '160133', 'ram1@gmail.com', NULL, NULL, '', 1, '', '2021-02-23 09:07:25', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(44, '160133', 'ram1@gmail.com', NULL, NULL, '', 1, '', '2021-02-23 10:36:56', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(45, '16004', 'murukeshs@apptomate.co', '2020-04-21 00:00:00', '45', 'https://inbox-ezcloud123.s3.amazonaws.com/inspiredecm/shawn.hummer_inspiredecm/EZ_Cloud_Test_Invoice_97pdf-textracted.json', 1, NULL, '2021-02-23 10:38:16', 0, '4455', 1, 1, 1, 'string', 'Manual', 1, '2021-02-23 11:18:41', 'shawn.hummer', '8870240610', NULL, '2021-02-21 00:00:00', '132, My Street,USA', '100100/2020', '1223233433', '3433', 'AAAA-GB-22-123', 'CY45002003579876543210987654', 'Attalla AL 35954.', 'USD', 200.00, 120.00, 20.00, 'Service fee', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Success', 'Fail', '{"data":[{"Invoice":"16004","Suppliername":"shawn.hummer","PoNumber":"4455","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Success","validateSupplierStatus":"Fail"}]}', '2021-02-25 18:38:41', 220.00, 'Extract', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(46, '160133', 'ram1@gmil.com', NULL, NULL, '', 1, '', '2021-03-02 15:04:10', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(47, '160133', 'ram1@gmil.com', NULL, NULL, '', 1, '', '2021-03-02 16:02:49', 0, '252133', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(48, '160133', 'ram@gmail.com', NULL, NULL, 'string', 1, '', '2021-03-03 13:00:31', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '47734734', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, 120.00, NULL, 'deswc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', 72.00, 'Manual', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(49, 'inv50', 'murukeshs@apptomate.co', '2021-03-08 00:00:00', '50.044', 'inv50.json', 1, 'inv50.pdf', '2021-03-08 15:51:40', 0, '48383', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'shawn.hummer', '8870240610', NULL, '2020-03-08 00:00:00', '132, My Street,', NULL, NULL, NULL, NULL, NULL, '132, My Street,USA', 'USD', 488.00, NULL, 34.44, 'desc', 'ram@gmail.com', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Success', '{"data":[{"Invoice":"inv50","Suppliername":"shawn.hummer","PoNumber":"48383","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Success"}]}', '2021-03-08 15:59:09', NULL, 'Extract', '', 'LAUREL', 'MD', '20723', 'US', '18', 'Invoice', 'Extract', NULL, NULL),
	(50, 'inv49', 'murukeshs@apptomate.co', '2020-03-08 00:00:00', '20.22', 'inv50.json', 1, NULL, '2021-03-08 15:59:05', 0, '43393', 1, 1, 1, 'Pending', NULL, NULL, NULL, 'murukesh', '8870240610', NULL, '2021-03-08 00:00:00', '', NULL, NULL, NULL, NULL, NULL, '', 'USD', 38.00, NULL, 33.00, 'desc', 'ram@gmail.com', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Manual', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Manual', 'Manual', 'Extract', 'Manual', 'Manual', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"inv49","Suppliername":"murukesh","PoNumber":"43393","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-08 19:36:48', NULL, 'Extract', '', '', '', '', '', '', 'PDF', 'Manual', NULL, NULL),
	(52, '09/28/2020', 'varuns@apptomate.co', NULL, '48.68', 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json', 1, 'https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf', '2021-03-10 12:01:18', 0, '144805', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'Stonewall Cable, Inc.', '', NULL, '2020-09-28 00:00:00', '', NULL, NULL, NULL, NULL, NULL, '', 'DOLLAR', NULL, NULL, NULL, '', 'swathit@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"09/28/2020","Suppliername":"Stonewall Cable, Inc.","PoNumber":"144805","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-10 15:21:26', NULL, 'Extract', '', '', '', '', '', '', 'INVOICE', 'Extract', NULL, NULL),
	(53, '09/28/2020', 'varuns@apptomate.co', NULL, '48.68', 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json', 1, 'https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf', '2021-03-10 12:02:39', 0, '144805', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'Stonewall Cable, Inc.', '', NULL, '2020-09-28 00:00:00', '', NULL, NULL, NULL, NULL, NULL, '', 'DOLLAR', NULL, NULL, NULL, '', 'swathit@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"09/28/2020","Suppliername":"Stonewall Cable, Inc.","PoNumber":"144805","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-10 15:21:26', NULL, 'Extract', '', '', '', '', '', '', 'INVOICE', 'Extract', NULL, NULL),
	(54, '09/28/2020', 'varuns@apptomate.co', NULL, '48.68', 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json', 1, 'https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf', '2021-03-10 13:20:51', 0, '144805', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'Stonewall Cable, Inc.', '', NULL, '2020-09-28 00:00:00', '', NULL, NULL, NULL, NULL, NULL, '', 'DOLLAR', NULL, NULL, NULL, '', 'swathit@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"09/28/2020","Suppliername":"Stonewall Cable, Inc.","PoNumber":"144805","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-10 15:21:26', NULL, 'Extract', '', '', '', '', '', '', 'INVOICE', 'Extract', NULL, NULL),
	(55, '09/28/2020', 'varuns@apptomate.co', NULL, '48.68', 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json', 1, 'https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf', '2021-03-10 15:21:23', 0, '144805', 1, 1, NULL, 'Approved', 'Extract', 1, '2021-03-19 16:28:34', 'Stonewall Cable, Inc.', '', NULL, '2020-09-28 00:00:00', '', NULL, NULL, NULL, NULL, NULL, '', 'DOLLAR', NULL, NULL, NULL, '', 'swathit@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Success', 'Fail', 'Fail', '{"data":[{"Invoice":"09/28/2020","Suppliername":"Stonewall Cable, Inc.","PoNumber":"144805","validateInvoiceStatus":"Success","validateInvoicePOStatus":"Fail","validateSupplierStatus":"Fail"}]}', '2021-03-11 12:52:55', NULL, 'Extract', '', '', '', '', '', '', 'INVOICE', 'Extract', NULL, NULL),
	(56, 'num0990', 'ram@gmail.com', '2021-03-16 00:00:00', '443', '', 1, 'num0990.pdf', '2021-03-16 12:35:43', 0, '477438', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'MICRONIX USA, LLC', '8870240610', NULL, '2021-03-16 00:00:00', '3506-B', '567896543', '22623782', '310', '', 'CH9300762011623852957', '3506-B', 'USD', 474.00, NULL, 474.00, 'desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"num0990","Suppliername":"MICRONIX USA, LLC","PoNumber":"477438","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-23 15:42:26', NULL, 'Extract', 'West Lake Center Drive', 'Santa Ana', 'CA', '92704', 'US', '19', 'Invoice', 'Extract', 'num09903778.jpg', NULL),
	(57, 'num0990', 'ram@gmail.com', '2021-03-16 00:00:00', '443', '', 1, 'num0990.pdf', '2021-03-19 12:30:24', 0, '477438', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'MICRONIX USA, LLC', '8870240610', NULL, '2021-03-16 00:00:00', '3506-B', '567896543', '22623782', '310', '', 'CH9300762011623852957', '3506-B', 'USD', 474.00, NULL, 474.00, 'desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"num0990","Suppliername":"MICRONIX USA, LLC","PoNumber":"477438","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-23 15:42:26', NULL, 'Extract', 'West Lake Center Drive', 'Santa Ana', 'CA', '92704', 'US', '19', 'Invoice', 'Extract', 'num0990.jpg', NULL),
	(58, 'num0990', 'ram@gmail.com', '2021-03-16 00:00:00', '443', '', 1, 'num0990.pdf', '2021-03-19 12:38:45', 0, '477438', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'MICRONIX USA, LLC', '8870240610', NULL, '2021-03-16 00:00:00', '3506-B', '567896543', '22623782', '310', '', 'CH9300762011623852957', '3506-B', 'USD', 474.00, NULL, 474.00, 'desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"num0990","Suppliername":"MICRONIX USA, LLC","PoNumber":"477438","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-23 15:42:26', NULL, 'Extract', 'West Lake Center Drive', 'Santa Ana', 'CA', '92704', 'US', '19', 'Invoice', 'Extract', 'num0990.jpg', NULL),
	(59, 'num0990', 'ram@gmail.com', '2021-03-16 00:00:00', '443', '', 1, 'num0990.pdf', '2021-03-19 12:40:56', 0, '477438', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'MICRONIX USA, LLC', '8870240610', NULL, '2021-03-16 00:00:00', '3506-B', '567896543', '22623782', '310', '', 'CH9300762011623852957', '3506-B', 'USD', 474.00, NULL, 474.00, 'desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"num0990","Suppliername":"MICRONIX USA, LLC","PoNumber":"477438","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-23 15:42:26', NULL, 'Extract', 'West Lake Center Drive', 'Santa Ana', 'CA', '92704', 'US', '19', 'Invoice', 'Extract', 'num0990.jpg', NULL),
	(60, 'num0990', 'ram@gmail.com', '2021-03-16 00:00:00', '443', '', 1, 'num0990.pdf', '2021-03-19 12:44:42', 0, '477438', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'MICRONIX USA, LLC', '8870240610', NULL, '2021-03-16 00:00:00', '3506-B', '567896543', '22623782', '310', '', 'CH9300762011623852957', '3506-B', 'USD', 474.00, NULL, 474.00, 'desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"num0990","Suppliername":"MICRONIX USA, LLC","PoNumber":"477438","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-23 15:42:26', NULL, 'Extract', 'West Lake Center Drive', 'Santa Ana', 'CA', '92704', 'US', '19', 'Invoice', 'Extract', 'num0990.jpg', NULL),
	(61, 'num0990', 'ram@gmail.com', '2021-03-16 00:00:00', '443', '', 1, 'num0990.pdf', '2021-03-19 13:37:49', 0, '477438', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'MICRONIX USA, LLC', '8870240610', NULL, '2021-03-16 00:00:00', '3506-B', '567896543', '22623782', '310', '', 'CH9300762011623852957', '3506-B', 'USD', 474.00, NULL, 474.00, 'desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"num0990","Suppliername":"MICRONIX USA, LLC","PoNumber":"477438","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-23 15:42:26', NULL, 'Extract', 'West Lake Center Drive', 'Santa Ana', 'CA', '92704', 'US', '19', 'Invoice', 'Extract', 'num0990.jpg', NULL),
	(62, 'num0990', 'murukeshs@apptomate.co', '2021-03-16 00:00:00', '443', '', 1, 'num0990.pdf', '2021-03-23 15:42:22', 0, '477438', 1, 1, NULL, 'Pending', 'Extract', NULL, NULL, 'MICRONIX USA, LLC', '8870240610', NULL, '2021-03-16 00:00:00', '3506-B', '567896543', '22623782', '310', '', 'CH9300762011623852957', '3506-B', 'USD', 474.00, NULL, 474.00, 'desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"num0990","Suppliername":"MICRONIX USA, LLC","PoNumber":"477438","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-03-23 15:42:26', NULL, 'Extract', 'West Lake Center Drive', 'Santa Ana', 'CA', '92704', 'US', '19', 'Invoice', 'Extract', 'num0990.jpg', NULL),
	(64, '1234', 'ram@gmail.com', '2021-04-04 00:00:00', '567.454', '1234.json', 1, '1234.pdf', '2021-04-04 22:29:58', 0, '8433', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn hummer', '88703407883', NULL, '2021-04-04 00:00:00', '', '', '', '', '', '', '', 'Dollor', 48833.00, NULL, 488.33, 'desd', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"1234","Suppliername":"shawn hummer","PoNumber":"8433","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-04-04 22:50:39', NULL, 'Extract', '', '', '', '', '', '', 'Invoice', 'Extract', '', NULL),
	(65, '1234', 'ram@gmail.com', '2021-04-04 00:00:00', '567.454', '1234.json', 1, '1234.pdf', '2021-04-04 22:33:24', 0, '8433', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn hummer', '88703407883', NULL, '2021-04-04 00:00:00', '', '', '', '', '', '', '', 'Dollor', 48833.00, NULL, 488.33, 'desd', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"1234","Suppliername":"shawn hummer","PoNumber":"8433","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-04-04 22:38:48', NULL, 'Extract', '', '', '', '', '', '', 'Invoice', 'Extract', '', NULL),
	(66, '160133', 'ram@gmail.com', NULL, NULL, '1234.json', 1, '', '2021-04-04 22:38:45', 0, '252133', 1, 1, NULL, 'Pending', 'Invoice', NULL, NULL, 'shawn.hummr', '8870240606', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, 100.00, NULL, 'Desc', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', 30030.00, 'Manual', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(67, '160133', 'supplier@dummy.com', NULL, NULL, '', 1, '', '2021-04-27 11:26:49', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '4848483', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(68, '160133', 'fhdnfh@gmail.com', NULL, NULL, '', 1, '', '2021-05-28 17:02:13', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '5544333', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', '', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(69, '160133', 'chitras@apptomate.co', NULL, NULL, 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1623149762592pdf-textracted.json', 1, '', '2021-06-08 16:44:00', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'swathit@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(70, '160133', 'chitras@apptomate.co', NULL, NULL, 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1623648478356pdf-textracted.json', 1, '', '2021-06-14 11:06:51', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'swathit@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(71, '160133', 'murukeshs@apptomate.co', NULL, NULL, 'https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1623648478356pdf-textracted.json', 1, '', '2021-06-14 18:53:59', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'swathit@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(72, '160133', 'murukeshs@apptomate.co', NULL, NULL, 'https://inbox-ezcloud123.s3.amazonaws.com/mailinator/testing9001_mailinator/1624868661279pdf-textracted.json', 1, '', '2021-07-01 16:34:54', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', 1, '2021-07-01 16:45:05', 'shawn.hummr', NULL, NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, NULL, 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(73, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-07-16 15:35:36', 0, '252133', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(74, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-07-16 15:40:17', 0, '252133', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(75, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-07-16 17:29:05', 0, '252133', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(76, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-07-16 17:32:00', 0, '252133', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(77, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-07-16 17:34:32', 0, '252133', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'murukeshs@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(78, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-07-16 17:35:31', 0, '252133', 1, 1, NULL, 'Pending', 'Message Broker', NULL, NULL, 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'kumar@gmail.com', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(79, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-07-16 17:38:35', 0, '252133', 1, 1, NULL, 'Pending', 'Message Broker', 54, '2021-07-20 15:11:46', 'shawn.hummr', '8870240610', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, '', 'kumar@gmail.com', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(80, '302 0033677', 'varuns@apptomate.co', NULL, '78750', 'https://inbox-notify-ezcloud-co.s3.amazonaws.com/apptomate/varuns_apptomate/1628425812259pdf-textracted.json', NULL, 'https://inbox-notify-ezcloud-co.s3.amazonaws.com/apptomate/varuns_apptomate/1628425812259.pdf', '2021-08-08 20:01:57', 0, '341742', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'Corning Tropel Corporation', NULL, NULL, '2020-08-24 00:00:00', '60 O\'Connor Roa', '', '914032-0122', '736198273', '', '', '60 O\'Connor Road', 'USD', 78750.00, NULL, 0.00, NULL, 'gayathris@ezcloud.io', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Valid', 'Valid', '{"data":[{"Invoice":"302 0033677","Suppliername":"Corning Tropel Corporation","PoNumber":"341742","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Valid","validateSupplierStatus":"Valid"}]}', '2021-08-08 20:02:02', NULL, 'Extract', '60 O\'Connor Road', 'Fairport', 'NY', '14450', 'US', '48', 'INVOICE', 'Extract', NULL, 0),
	(81, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2021-09-07 22:15:05', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '7748383', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'desc', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(82, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2021-09-07 22:15:39', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '7748383', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'desc', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(83, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2021-09-07 22:16:37', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '7748383', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'desc', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(84, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2021-09-07 22:17:27', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '7748383', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'desc', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(85, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2021-09-07 22:18:22', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '7748383', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'desc', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(86, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2021-09-07 22:19:09', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '7748383', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'desc', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(87, '160133', 'murukeshs@apptomate.co', NULL, NULL, '', 1, '', '2021-09-08 18:56:33', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'murukeshhh@gmail.com', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(88, '160133', 'smith@apptomate.co', NULL, NULL, '', 1, '', '2021-09-08 18:57:43', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'murukeshhh@gmail.com', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(89, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-08 18:58:44', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(90, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-08 19:10:18', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(91, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-08 19:21:14', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(92, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 11:56:11', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(93, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 11:58:48', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(94, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:28:31', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(95, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:43:07', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(96, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:45:34', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(97, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:50:12', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(98, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:50:51', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(99, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:52:54', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(100, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:54:01', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(101, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:54:25', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(102, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 12:55:44', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(103, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 13:15:28', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(104, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, '', '2021-09-11 13:20:37', 0, '252133', 1, 1, NULL, 'Pending', 'Manual', NULL, NULL, 'shawn.hummr', '', NULL, NULL, '', '', '', '', '', '', '', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Doesn\'t exist in ERP', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummr","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Doesn\'t exist in ERP"}]}', '2021-09-11 13:46:26', NULL, 'Extract', '', '', '', '', '', '', 'string', 'Extract', 'string', 1),
	(105, '160133', 'murukeshhh@gmail.com', NULL, NULL, '', 1, NULL, '2021-09-11 13:20:52', 0, '252133', 1, 1, NULL, 'Pending', NULL, NULL, NULL, 'shawn.hummer', '', NULL, NULL, '132, My Street,', '', '', '', '', '', '132, My Street,USA', 'string', NULL, NULL, NULL, 'string', 'smith@apptomate.co', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Manual', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Extract', 'Valid', 'Doesn\'t exist in ERP', 'Valid', '{"data":[{"Invoice":"160133","Suppliername":"shawn.hummer","PoNumber":"252133","validateInvoiceStatus":"Valid","validateInvoicePOStatus":"Doesn\'t exist in ERP","validateSupplierStatus":"Valid"}]}', '2021-09-11 14:51:03', NULL, 'Extract', '', 'LAUREL', 'MD', '20723', 'US', '18', 'string', 'Extract', 'string', 1);
/*!40000 ALTER TABLE `tblinvoicedetails` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblinvoicefieldlist
CREATE TABLE IF NOT EXISTS `tblinvoicefieldlist` (
  `fieldListId` int(11) NOT NULL AUTO_INCREMENT,
  `fieldName` varchar(50) DEFAULT NULL,
  `moduleName` varchar(50) DEFAULT NULL,
  `isActive` tinyint(1) DEFAULT NULL,
  `columnName` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`fieldListId`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblinvoicefieldlist: ~30 rows (approximately)
/*!40000 ALTER TABLE `tblinvoicefieldlist` DISABLE KEYS */;
INSERT IGNORE INTO `tblinvoicefieldlist` (`fieldListId`, `fieldName`, `moduleName`, `isActive`, `columnName`) VALUES
	(1, 'Operating Unit', 'Invoice', 0, 'operatingUnit'),
	(2, 'Source', 'Invoice', 0, NULL),
	(3, 'Invoice Number', 'Invoice', 1, 'invoiceNumber'),
	(4, 'Invoice Date', 'Invoice', 1, 'invoiceDate'),
	(5, 'Invoice Type', 'Invoice', 0, NULL),
	(6, 'Vendor/Supplier Name', 'Invoice', 1, 'name'),
	(7, 'Vendor/Supplier Number', 'Invoice', 1, 'phoneNumber'),
	(8, 'Vendor/Supplier Site', 'Invoice', 1, 'supplierSite'),
	(9, 'Vendor/Supplier Tax Number', 'Invoice', 1, 'taxNumber'),
	(10, 'Vendor/Supplier Bank Account', 'Invoice', 1, 'bankAccount'),
	(11, 'Sort Code', 'Invoice', 1, 'sortCode'),
	(12, 'BIC/SWIFT', 'Invoice', 1, 'swift'),
	(13, 'IBAN', 'Invoice', 1, 'iban'),
	(14, 'Purchase Order Number', 'Invoice', 1, 'orderNumber'),
	(15, 'Vendor/Supplier Addresss', 'Invoice', 1, 'supplierAddress'),
	(16, 'Invoice Currency', 'Invoice', 1, 'invoiceCurrency'),
	(17, 'Invoice Amount', 'Invoice', 1, 'invoiceAmount'),
	(18, 'Paid Amount', 'Invoice', 1, 'paidAmount'),
	(19, 'Due Amount', 'Invoice', 1, 'dueAmount'),
	(20, 'Tax Total', 'Invoice', 1, 'taxTotal'),
	(21, 'Due Date', 'Invoice', 1, 'dueDate'),
	(22, 'Invoice Description', 'Invoice', 1, 'invoiceDescription'),
	(23, 'Payments Terms', 'Invoice', 0, NULL),
	(24, 'Operating Unit', 'Invoice Line', 1, 'operatingUnit'),
	(25, 'Invoice Line Number', 'Invoice Line', 1, 'invoiceLineNumber'),
	(26, 'Invoice Line Type', 'Invoice Line', 1, 'invoiceLineType'),
	(27, 'Invoice Line Amount', 'Invoice Line', 1, 'invoiceLineAmount'),
	(28, 'Distribution Accounts', 'Invoice Line', 0, NULL),
	(29, 'Supplier Email', 'Invoice', 1, 'senderEmail'),
	(30, 'Document Type', 'Invoice', 1, 'documentType');
/*!40000 ALTER TABLE `tblinvoicefieldlist` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblinvoiceline
CREATE TABLE IF NOT EXISTS `tblinvoiceline` (
  `invoiceLineId` int(11) NOT NULL AUTO_INCREMENT,
  `invoiceId` int(11) DEFAULT NULL,
  `operatingUnit` varchar(30) DEFAULT NULL,
  `invoiceLineNumber` varchar(30) DEFAULT NULL,
  `invoiceLineType` varchar(30) DEFAULT NULL,
  `invoiceLineAmount` decimal(17,2) DEFAULT NULL,
  PRIMARY KEY (`invoiceLineId`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblinvoiceline: ~11 rows (approximately)
/*!40000 ALTER TABLE `tblinvoiceline` DISABLE KEYS */;
INSERT IGNORE INTO `tblinvoiceline` (`invoiceLineId`, `invoiceId`, `operatingUnit`, `invoiceLineNumber`, `invoiceLineType`, `invoiceLineAmount`) VALUES
	(1, 23, 'string', 'string', 'string', 0.00),
	(2, 12, 'unit1', '1', 'type1', 10.00),
	(3, 10, 'Line', '1', 'Normal', 10.00),
	(4, 23, NULL, 'string', NULL, 0.00),
	(5, 11, 'unit2', '2', 'type2', 20.00),
	(6, 12, 'unit2', '2', 'type2', 20.00),
	(7, 22, 'Unit 1', '3344', 'Type1', 10.00),
	(8, 13, 'unit1', '1', 'type1', 10.00),
	(9, 11, 'unit1', '1', 'type1', 10.00),
	(10, 13, 'unit2', '2', 'type2', 20.00),
	(11, 80, 'unit1', 'num 1', 'type 1', 10.00);
/*!40000 ALTER TABLE `tblinvoiceline` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblinvoicelockdetails
CREATE TABLE IF NOT EXISTS `tblinvoicelockdetails` (
  `lockId` int(11) NOT NULL AUTO_INCREMENT,
  `invoiceId` int(11) DEFAULT NULL,
  `lockedDate` datetime DEFAULT NULL,
  `lockedBy` int(11) DEFAULT NULL,
  PRIMARY KEY (`lockId`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblinvoicelockdetails: ~1 rows (approximately)
/*!40000 ALTER TABLE `tblinvoicelockdetails` DISABLE KEYS */;
INSERT IGNORE INTO `tblinvoicelockdetails` (`lockId`, `invoiceId`, `lockedDate`, `lockedBy`) VALUES
	(7, 1000, '2021-04-05 22:50:19', 1);
/*!40000 ALTER TABLE `tblinvoicelockdetails` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblinvoicelog
CREATE TABLE IF NOT EXISTS `tblinvoicelog` (
  `logId` int(11) NOT NULL AUTO_INCREMENT,
  `invoiceId` int(11) DEFAULT NULL,
  `comment` varchar(250) DEFAULT NULL,
  `actionBy` int(11) DEFAULT NULL,
  `actionDate` datetime DEFAULT NULL,
  PRIMARY KEY (`logId`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblinvoicelog: ~3 rows (approximately)
/*!40000 ALTER TABLE `tblinvoicelog` DISABLE KEYS */;
INSERT IGNORE INTO `tblinvoicelog` (`logId`, `invoiceId`, `comment`, `actionBy`, `actionDate`) VALUES
	(1, 79, 'Edit', 54, '2021-07-20 15:06:18'),
	(2, 79, 'Edit', 55, '2021-07-20 15:06:41'),
	(3, 79, 'Pending', 54, '2021-07-20 15:11:46');
/*!40000 ALTER TABLE `tblinvoicelog` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tbllog
CREATE TABLE IF NOT EXISTS `tbllog` (
  `logId` int(11) NOT NULL AUTO_INCREMENT,
  `functionName` varchar(50) DEFAULT NULL,
  `functionData` text DEFAULT NULL,
  `createdDate` datetime DEFAULT NULL,
  PRIMARY KEY (`logId`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tbllog: ~38 rows (approximately)
/*!40000 ALTER TABLE `tbllog` DISABLE KEYS */;
INSERT IGNORE INTO `tbllog` (`logId`, `functionName`, `functionData`, `createdDate`) VALUES
	(10, 'save', 'Data', '2021-03-19 12:53:25'),
	(11, 'saveInvoice', '{"Error":{"status":"Error","message":"Test Message"}}', '2021-03-19 13:04:07'),
	(12, 'saveInvoice', '{"Error":{"status":"Error","message":"Test Message"},"RequestData":{"invoiceNumber":"num0990","senderEmail":"ram@gmail.com","dueDate":"2021-03-15T18:30:00.000Z","dueAmount":443,"textractJson":"","filepath":"num0990.pdf","textTractStatus":true,"orderNumber":"477438","success":true,"textractFailed":true,"receiverEmail":"murukeshs@apptomate.co","status":"Pending","name":"MICRONIX USA, LLC","phoneNumber":"8870240610","invoiceDate":"2021-03-15T18:30:00.000Z","invoiceDescription":"desc","documentType":"Invoice","invoiceAmount":474,"taxTotal":474,"invoiceCurrency":"USD","imageFilePath":"num0990.jpg","invoiceType":"Extract"}}', '2021-03-19 13:05:10'),
	(13, 'approveInvoice', '{"Error":{"message":"Converting circular structure to JSON\\n    --> starting at object with constructor \'ClientRequest\'\\n    |     property \'socket\' -> object with constructor \'TLSSocket\'\\n    --- property \'_httpMessage\' closes the circle","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 15:57:33'),
	(14, 'approveInvoice', '{"Error":{"message":"Converting circular structure to JSON\\n    --> starting at object with constructor \'ClientRequest\'\\n    |     property \'socket\' -> object with constructor \'TLSSocket\'\\n    --- property \'_httpMessage\' closes the circle","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 15:58:27'),
	(15, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:09:22'),
	(16, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:09:41'),
	(17, 'approveInvoice', '{"Error":{"message":"Converting circular structure to JSON\\n    --> starting at object with constructor \'ClientRequest\'\\n    |     property \'socket\' -> object with constructor \'TLSSocket\'\\n    --- property \'_httpMessage\' closes the circle","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:12:02'),
	(18, 'approveInvoice', '{"Error":{"message":"Converting circular structure to JSON\\n    --> starting at object with constructor \'ClientRequest\'\\n    |     property \'socket\' -> object with constructor \'TLSSocket\'\\n    --- property \'_httpMessage\' closes the circle","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:13:49'),
	(19, 'approveInvoice', '{"Error":{"message":"Converting circular structure to JSON\\n    --> starting at object with constructor \'ClientRequest\'\\n    |     property \'socket\' -> object with constructor \'TLSSocket\'\\n    --- property \'_httpMessage\' closes the circle","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:14:42'),
	(20, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:15:19'),
	(21, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:15:49'),
	(22, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Apptoved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:14:41.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:16:50'),
	(23, 'approveInvoice', '{"Error":{"message":"Converting circular structure to JSON\\n    --> starting at object with constructor \'ClientRequest\'\\n    |     property \'socket\' -> object with constructor \'TLSSocket\'\\n    --- property \'_httpMessage\' closes the circle","status":"Error"},"RequestData":{"userId":1,"invoiceId":55,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":55,"invoiceNumber":"09/28/2020","senderEmail":"varuns@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1615302449502pdf-textracted.json","textTractStatus":1,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/varuns_apptomate/1615302449502.pdf","imageFilePath":null,"invCreatedDate":"2021-03-10T09:51:23.000Z","orderNumber":"144805","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Approved","invoiceType":"Extract","actionBy":1,"actionDate":"2021-03-19T10:50:08.000Z","name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"","taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"DOLLAR","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"09/28/2020\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-11T07:22:55.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:21:04'),
	(24, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":61,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":61,"invoiceNumber":"num0990","senderEmail":"ram@gmail.com","dueDate":"2021-03-15T18:30:00.000Z","dueDateYYYMMDD":"2021-03-15T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":443,"textractJson":"","textTractStatus":1,"filePath":"num0990.pdf","imageFilePath":"num0990.jpg","invCreatedDate":"2021-03-19T08:07:49.000Z","orderNumber":"477438","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Pending","invoiceType":"Extract","actionBy":null,"actionDate":null,"name":"MICRONIX USA, LLC","invoiceDate":"2021-03-15T18:30:00.000Z","supplierSite":"3506-B","taxNumber":"567896543","bankAccount":"22623782","sortCode":"310","swift":"","iban":"CH9300762011623852957","supplierAddress2":"West Lake Center Drive","city":"Santa Ana","state":"CA","postalCode":"92704","country":"US","supplierId":"19","supplierAddress":"3506-B","invoiceCurrency":"USD","invoiceAmount":474,"paidAmount":null,"taxTotal":474,"totalAmount":null,"invoiceDescription":"desc","phoneNumber":"8870240610","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":10,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"apptomate.png","companyName":"Apptomate","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"Invoice","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Doesn\'t exist in ERP","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"num0990\\",\\"Suppliername\\":\\"MICRONIX USA, LLC\\",\\"PoNumber\\":\\"477438\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Doesn\'t exist in ERP\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-03-19T08:07:52.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-03-19 16:35:46'),
	(25, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":19,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":19,"invoiceNumber":"1603","senderEmail":"murukeshs@apptomate.co","dueDate":"2020-04-20T18:30:00.000Z","dueDateYYYMMDD":"2020-04-20T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":45,"textractJson":"","textTractStatus":1,"filePath":"","imageFilePath":null,"invCreatedDate":"2020-11-03T09:51:16.000Z","orderNumber":"4455","success":1,"textractFailed":1,"manualExtractFailed":1,"status":"string","invoiceType":"Non-PO","actionBy":null,"actionDate":null,"name":"","invoiceDate":null,"supplierSite":null,"taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":null,"invoiceCurrency":null,"invoiceAmount":null,"paidAmount":null,"taxTotal":0,"totalAmount":null,"invoiceDescription":null,"phoneNumber":"","mntName":"Nov","invoiceYear":2020,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":10,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"apptomate.png","companyName":"Apptomate","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":null,"documentTypeTR":null,"paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"1068\\",\\"PoNumber\\":\\"7744\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-02T10:32:52.000Z","requestId":null,"supplierCompanyName":"Apptomate"}]}}}', '2021-03-23 14:35:39'),
	(26, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":19,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":19,"invoiceNumber":"1603","senderEmail":"murukeshs@apptomate.co","dueDate":"2020-04-20T18:30:00.000Z","dueDateYYYMMDD":"2020-04-20T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":45,"textractJson":"","textTractStatus":1,"filePath":"","imageFilePath":null,"invCreatedDate":"2020-11-03T09:51:16.000Z","orderNumber":"4455","success":1,"textractFailed":1,"manualExtractFailed":1,"status":"string","invoiceType":"Non-PO","actionBy":null,"actionDate":null,"name":"","invoiceDate":null,"supplierSite":null,"taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":null,"invoiceCurrency":null,"invoiceAmount":null,"paidAmount":null,"taxTotal":0,"totalAmount":null,"invoiceDescription":null,"phoneNumber":"","mntName":"Nov","invoiceYear":2020,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":10,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"apptomate.png","companyName":"Apptomate","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":null,"documentTypeTR":null,"paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"1068\\",\\"PoNumber\\":\\"7744\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-02T10:32:52.000Z","requestId":null,"supplierCompanyName":"Apptomate"}]}}}', '2021-03-23 14:37:34'),
	(27, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":19,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":19,"invoiceNumber":"1603","senderEmail":"murukeshs@apptomate.co","dueDate":"2020-04-20T18:30:00.000Z","dueDateYYYMMDD":"2020-04-20T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":45,"textractJson":"","textTractStatus":1,"filePath":"","imageFilePath":null,"invCreatedDate":"2020-11-03T09:51:16.000Z","orderNumber":"4455","success":1,"textractFailed":1,"manualExtractFailed":1,"status":"string","invoiceType":"Non-PO","actionBy":null,"actionDate":null,"name":"","invoiceDate":null,"supplierSite":null,"taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":null,"invoiceCurrency":null,"invoiceAmount":null,"paidAmount":null,"taxTotal":0,"totalAmount":null,"invoiceDescription":null,"phoneNumber":"","mntName":"Nov","invoiceYear":2020,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":10,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"apptomate.png","companyName":"Apptomate","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":null,"documentTypeTR":null,"paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"1068\\",\\"PoNumber\\":\\"7744\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-02T10:32:52.000Z","requestId":null,"supplierCompanyName":"Apptomate"}]}}}', '2021-03-23 14:40:42'),
	(28, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":19,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":19,"invoiceNumber":"1603","senderEmail":"murukeshs@apptomate.co","dueDate":"2020-04-20T18:30:00.000Z","dueDateYYYMMDD":"2020-04-20T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":45,"textractJson":"","textTractStatus":1,"filePath":"","imageFilePath":null,"invCreatedDate":"2020-11-03T09:51:16.000Z","orderNumber":"4455","success":1,"textractFailed":1,"manualExtractFailed":1,"status":"string","invoiceType":"Non-PO","actionBy":null,"actionDate":null,"name":"","invoiceDate":null,"supplierSite":null,"taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":null,"invoiceCurrency":null,"invoiceAmount":null,"paidAmount":null,"taxTotal":0,"totalAmount":null,"invoiceDescription":null,"phoneNumber":"","mntName":"Nov","invoiceYear":2020,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":10,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"apptomate.png","companyName":"Apptomate","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":null,"documentTypeTR":null,"paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"1068\\",\\"PoNumber\\":\\"7744\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-02T10:32:52.000Z","requestId":null,"supplierCompanyName":"Apptomate"}]}}}', '2021-03-23 14:42:11'),
	(29, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":19,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":19,"invoiceNumber":"1603","senderEmail":"murukeshs@apptomate.co","dueDate":"2020-04-20T18:30:00.000Z","dueDateYYYMMDD":"2020-04-20T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":45,"textractJson":"","textTractStatus":1,"filePath":"","imageFilePath":null,"invCreatedDate":"2020-11-03T09:51:16.000Z","orderNumber":"4455","success":1,"textractFailed":1,"manualExtractFailed":1,"status":"string","invoiceType":"Non-PO","actionBy":null,"actionDate":null,"name":"","invoiceDate":null,"supplierSite":null,"taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":null,"invoiceCurrency":null,"invoiceAmount":null,"paidAmount":null,"taxTotal":0,"totalAmount":null,"invoiceDescription":null,"phoneNumber":"","mntName":"Nov","invoiceYear":2020,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":10,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"apptomate.png","companyName":"Apptomate","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":null,"documentTypeTR":null,"paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"1068\\",\\"PoNumber\\":\\"7744\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Fail\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-03-02T10:32:52.000Z","requestId":null,"supplierCompanyName":"Apptomate"}]}}}', '2021-03-23 14:43:46'),
	(30, 'updateInvoice', '{"Error":{"message":"ER_BAD_FIELD_ERROR: Unknown column \'filePath\' in \'where clause\'","status":"Error"},"RequestData":{"invoiceId":0,"invoiceNumber":"numb123","senderEmail":"murukeshs@apptomate.co","dueDate":"2021-03-22T18:30:00.000Z","dueAmount":55,"textractJson":"numb123.json","filepath":"numb123.pdf","textTractStatus":true,"orderNumber":"48483","success":true,"textractFailed":true,"receiverEmail":"murukeshhh@gmail.com","status":"Pending","name":"Controlled Motion Solutions, Inc","phoneNumber":"8870240610","invoiceDate":"2021-03-22T18:30:00.000Z","invoiceDescription":"desc","documentType":"Invoice","invoiceAmount":1200,"taxTotal":0,"invoiceCurrency":"USD","imageFilePath":"","source":"Message Broker","action":"Insert","uploadBy":"Supplier","invoiceType":"Extract"}}', '2021-03-23 16:58:04'),
	(31, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":63,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":63,"invoiceNumber":"numb123","senderEmail":"murukeshs@apptomate.co","dueDate":"2021-03-22T18:30:00.000Z","dueDateYYYMMDD":"2021-03-22T18:30:00.000Z","receiverEmail":"murukeshhh@gmail.com","dueAmount":55,"textractJson":"numb123.json","textTractStatus":1,"filePath":"numb123.pdf","imageFilePath":"","invCreatedDate":"2021-03-23T11:23:36.000Z","orderNumber":"48483","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Pending","invoiceType":"Message Broker","actionBy":null,"actionDate":null,"name":"Controlled Motion Solutions, Inc","invoiceDate":"2021-03-22T18:30:00.000Z","supplierSite":"","taxNumber":"","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"USD","invoiceAmount":1200,"paidAmount":null,"taxTotal":0,"totalAmount":null,"invoiceDescription":"desc","phoneNumber":"8870240610","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"murukeshhh@gmail.com","teamId":18,"autoApproval":20,"teamCreatedDate":"2021-02-23T12:18:11.000Z","teamType":"Open Registration","companyLogo":"","companyName":"Sup 1","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"Invoice","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Doesn\'t exist in ERP","supplierStatus":"Doesn\'t exist in ERP","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"numb123\\",\\"Suppliername\\":\\"Controlled Motion Solutions, Inc\\",\\"PoNumber\\":\\"48483\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Doesn\'t exist in ERP\\",\\"validateSupplierStatus\\":\\"Doesn\'t exist in ERP\\"}]}","validationRequestDate":"2021-03-23T11:57:57.000Z","requestId":null,"supplierCompanyName":"Apptomate"}]}}}', '2021-03-24 13:30:17'),
	(32, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":63,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":63,"invoiceNumber":"numb123","senderEmail":"murukeshs@apptomate.co","dueDate":"2021-03-22T18:30:00.000Z","dueDateYYYMMDD":"2021-03-22T18:30:00.000Z","receiverEmail":"murukeshhh@gmail.com","dueAmount":55,"textractJson":"numb123.json","textTractStatus":1,"filePath":"numb123.pdf","imageFilePath":"","invCreatedDate":"2021-03-23T11:23:36.000Z","orderNumber":"48483","success":1,"textractFailed":1,"manualExtractFailed":null,"status":"Pending","invoiceType":"Message Broker","actionBy":null,"actionDate":null,"name":"Controlled Motion Solutions, Inc","invoiceDate":"2021-03-22T18:30:00.000Z","supplierSite":"","taxNumber":"","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"","city":"","state":"","postalCode":"","country":"","supplierId":"","supplierAddress":"","invoiceCurrency":"USD","invoiceAmount":1200,"paidAmount":null,"taxTotal":0,"totalAmount":null,"invoiceDescription":"desc","phoneNumber":"8870240610","mntName":"Mar","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"murukeshhh@gmail.com","teamId":18,"autoApproval":20,"teamCreatedDate":"2021-02-23T12:18:11.000Z","teamType":"Open Registration","companyLogo":"https://logoez.s3.amazonaws.com/final-2-2_2021-03-02-08-25-14_2021-03-02-09-49-04.png","companyName":"Sup 1","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"Invoice","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Doesn\'t exist in ERP","supplierStatus":"Doesn\'t exist in ERP","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"numb123\\",\\"Suppliername\\":\\"Controlled Motion Solutions, Inc\\",\\"PoNumber\\":\\"48483\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Doesn\'t exist in ERP\\",\\"validateSupplierStatus\\":\\"Doesn\'t exist in ERP\\"}]}","validationRequestDate":"2021-03-23T11:57:57.000Z","requestId":null,"supplierCompanyName":"Apptomate"}]}}}', '2021-03-24 13:33:18'),
	(33, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":66,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":66,"invoiceNumber":"inv344","senderEmail":"ram@gmail.com","dueDate":"2021-04-03T18:30:00.000Z","dueDateYYYMMDD":"2021-04-03T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":222,"textractJson":"1234.json","textTractStatus":1,"filePath":"","imageFilePath":"","invCreatedDate":"2021-04-04T17:08:45.000Z","orderNumber":"3392","success":1,"textractFailed":1,"manualExtractFailed":1,"status":"Pending","invoiceType":"Invoice","actionBy":null,"actionDate":null,"name":"shawn.hummer","invoiceDate":"2021-04-03T18:30:00.000Z","supplierSite":"132, My Street,","taxNumber":"","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"","city":"LAUREL","state":"MD","postalCode":"20723","country":"US","supplierId":"18","supplierAddress":"132, My Street,USA","invoiceCurrency":"USD","invoiceAmount":1000,"paidAmount":100,"taxTotal":10,"totalAmount":30030,"invoiceDescription":"Desc","phoneNumber":"8870240606","mntName":"Apr","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":200,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"https://logoez.s3.amazonaws.com/final-2-2_2021-03-02-08-25-14_2021-03-02-09-49-04.png","companyName":"Apptomate Soft","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Manual","dueDateTR":"Extract","dueAmountTR":"Manual","orderNumberTR":"Manual","invoiceDateTR":"Extract","nameTR":"Manual","phoneNumberTR":"Manual","supplierSiteTR":"Manual","taxNumberTR":"Manual","bankAccountTR":"Manual","sortCodeTR":"Manual","swiftTR":"Manual","ibanTR":"Manual","supplierAddressTR":"Manual","invoiceCurrencyTR":"Manual","invoiceAmountTR":"Manual","documentType":"Invoice","documentTypeTR":"Extract","paidAmountTR":"Manual","taxTotalTR":"Manual","invoiceDescriptionTR":"Manual","totalAmountTR":"Manual","invoiceStatus":"Valid","invoicePOStatus":"Valid","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"inv344\\",\\"Suppliername\\":\\"shawn.hummer\\",\\"PoNumber\\":\\"3392\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Valid\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-04-05T17:29:17.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-04-05 23:01:43'),
	(34, 'updateInvoice', '{"Error":{"message":"ER_BAD_FIELD_ERROR: Unknown column \'pimageFilePath.extractEngineFailed\' in \'field list\'","status":"Error"},"RequestData":{"invoiceId":68,"invoiceNumber":"tetst","senderEmail":"fhdnfh@gmail.com","dueDate":"2021-05-04T18:30:00.000Z","dueAmount":55,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"","success":true,"textractFailed":true,"receiverEmail":"","status":"Pending","name":"murukesh","phoneNumber":"5544333","invoiceDate":null,"invoiceDescription":"","documentType":"","invoiceAmount":53,"taxTotal":444,"invoiceCurrency":"USD","imageFilePath":"","source":"","action":"","uploadBy":"","invoiceType":"Extract"}}', '2021-05-28 17:04:04'),
	(35, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":45,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":45,"invoiceNumber":"16004","senderEmail":"shawn.hummer@inspiredecm.com","dueDate":"2020-04-20T18:30:00.000Z","dueDateYYYMMDD":"2020-04-20T18:30:00.000Z","receiverEmail":null,"dueAmount":45,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/inspiredecm/shawn.hummer_inspiredecm/EZ_Cloud_Test_Invoice_97pdf-textracted.json","textTractStatus":1,"filePath":null,"imageFilePath":null,"invCreatedDate":"2021-02-23T05:08:16.000Z","orderNumber":"4455","success":1,"textractFailed":1,"manualExtractFailed":1,"extractEngineFailed":null,"status":"string","invoiceType":"Manual","actionBy":1,"actionDate":"2021-02-23T05:48:41.000Z","name":"shawn.hummer","invoiceDate":"2021-02-20T18:30:00.000Z","supplierSite":"132, My Street,USA","taxNumber":"100100/2020","bankAccount":"1223233433","sortCode":"3433","swift":"AAAA-GB-22-123","iban":"CY45002003579876543210987654","supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":"Attalla AL 35954.","invoiceCurrency":"USD","invoiceAmount":200,"paidAmount":120,"taxTotal":20,"totalAmount":220,"invoiceDescription":"Service fee","phoneNumber":"8870240610","mntName":"Feb","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":null,"documentTypeTR":null,"paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Success","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"16004\\",\\"Suppliername\\":\\"shawn.hummer\\",\\"PoNumber\\":\\"4455\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Success\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-02-25T13:08:41.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-05-30 15:42:33'),
	(36, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":45,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":45,"invoiceNumber":"16004","senderEmail":"murukeshs@apptomate.co","dueDate":"2020-04-20T18:30:00.000Z","dueDateYYYMMDD":"2020-04-20T18:30:00.000Z","receiverEmail":"murukeshs@apptomate.co","dueAmount":45,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/inspiredecm/shawn.hummer_inspiredecm/EZ_Cloud_Test_Invoice_97pdf-textracted.json","textTractStatus":1,"filePath":null,"imageFilePath":null,"invCreatedDate":"2021-02-23T05:08:16.000Z","orderNumber":"4455","success":1,"textractFailed":1,"manualExtractFailed":1,"extractEngineFailed":null,"status":"string","invoiceType":"Manual","actionBy":1,"actionDate":"2021-02-23T05:48:41.000Z","name":"shawn.hummer","invoiceDate":"2021-02-20T18:30:00.000Z","supplierSite":"132, My Street,USA","taxNumber":"100100/2020","bankAccount":"1223233433","sortCode":"3433","swift":"AAAA-GB-22-123","iban":"CY45002003579876543210987654","supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":"Attalla AL 35954.","invoiceCurrency":"USD","invoiceAmount":200,"paidAmount":120,"taxTotal":20,"totalAmount":220,"invoiceDescription":"Service fee","phoneNumber":"8870240610","mntName":"Feb","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":1,"autoApproval":200,"teamCreatedDate":"2020-10-01T09:23:09.000Z","teamType":null,"companyLogo":"https://logoez.s3.amazonaws.com/final-2-2_2021-03-02-08-25-14_2021-03-02-09-49-04.png","companyName":"Apptomate Soft","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":null,"documentTypeTR":null,"paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Success","invoicePOStatus":"Success","supplierStatus":"Fail","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"16004\\",\\"Suppliername\\":\\"shawn.hummer\\",\\"PoNumber\\":\\"4455\\",\\"validateInvoiceStatus\\":\\"Success\\",\\"validateInvoicePOStatus\\":\\"Success\\",\\"validateSupplierStatus\\":\\"Fail\\"}]}","validationRequestDate":"2021-02-25T13:08:41.000Z","requestId":null,"supplierCompanyName":"Apptomate Soft"}]}}}', '2021-05-30 16:22:28'),
	(37, 'validationsInvoice', '{"Error":"Request failed with status code 401","RequestData":{"invoiceId":0,"invoiceNumber":"302 0033677","senderEmail":"chitras@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"swathit@apptomate.co","dueAmount":78750,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1623648478356pdf-textracted.json","textTractStatus":null,"filePath":"https://inbox-ezcloud123.s3.amazonaws.com/apptomate/chitras_apptomate/1623648478356.pdf","imageFilePath":null,"invCreatedDate":"2021-06-14T05:27:58.000Z","orderNumber":"341742","success":0,"textractFailed":0,"manualExtractFailed":null,"extractEngineFailed":0,"status":"Pending","invoiceType":"Extract","actionBy":null,"actionDate":null,"name":"Corning Tropel Corporation","invoiceDate":"2020-08-24T00:00:00.000Z","supplierSite":null,"taxNumber":null,"bankAccount":null,"sortCode":null,"swift":null,"iban":null,"supplierAddress2":null,"city":null,"state":null,"postalCode":null,"country":null,"supplierId":null,"supplierAddress":null,"invoiceCurrency":"USD","invoiceAmount":78750,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":null,"phoneNumber":null,"mntName":"Jun","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"swathit@apptomate.co","teamId":26,"autoApproval":9990,"teamCreatedDate":"2021-01-21T16:21:51.000Z","teamType":"Open Registration","companyLogo":"https://logoez.s3.amazonaws.com/final-2-2_2021-03-02-08-25-14_2021-03-02-09-49-04.png","companyName":"Apptomate pvt ltd","teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Fail","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"Request failed with status code 401","validationRequestDate":"2021-06-14T05:29:32.000Z","requestId":11,"supplierCompanyName":"tcs","filepath":"","source":"Manual","invoiceData":{"data":[{"invoiceNumber":"302 0033677","orderNumber":"341742","name":"Corning Tropel Corporation"}]}}}', '2021-06-14 11:06:53'),
	(38, 'validationsInvoice', '{"Error":"connect ETIMEDOUT 147.154.26.210:443","RequestData":{"invoiceId":71,"invoiceNumber":"302 0033677","senderEmail":"chitras@apptomate.co","dueDate":null,"dueAmount":78750,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1623648478356pdf-textracted.json","textTractStatus":null,"filePath":"","createdDate":"2021-06-14T13:23:59.000Z","isDeleted":0,"orderNumber":"341742","success":0,"textractFailed":0,"manualExtractFailed":null,"status":"Pending","invoiceType":"Extract","actionBy":null,"actionDate":null,"name":"Corning Tropel Corporation","phoneNumber":null,"createdBy":null,"invoiceDate":"2020/10/23","supplierSite":"60 O\'Connor Roa","taxNumber":"","bankAccount":"914032-0122","sortCode":"736198273","swift":"","iban":"","supplierAddress":"60 O\'Connor Road","invoiceCurrency":"USD","invoiceAmount":78750,"paidAmount":null,"taxTotal":null,"invoiceDescription":null,"receiverEmail":"swathit@apptomate.co","invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","invoiceStatus":"Fail","invoicePOStatus":"Fail","supplierStatus":"Fail","validationResponse":"connect ETIMEDOUT 147.154.26.210:443","validationRequestDate":"2021-06-14T13:24:02.000Z","totalAmount":null,"totalAmountTR":"Extract","supplierAddress2":"60 O\'Connor Road","city":"Fairport","state":"NY","postalCode":"14450","country":"US","supplierId":"48","documentType":"INVOICE","documentTypeTR":"Extract","imageFilePath":null,"extractEngineFailed":0,"filepath":"","invoiceData":{"data":[{"invoiceNumber":"302 0033677","orderNumber":"341742","name":"Corning Tropel Corporation"}]}}}', '2021-06-23 15:12:40'),
	(39, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":71,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":71,"invoiceNumber":"302 0033677","senderEmail":"murukeshs@apptomate.co","dueDate":"2021-06-28T18:30:00.000Z","dueDateYYYMMDD":"2021-06-28T18:30:00.000Z","receiverEmail":"swathit@apptomate.co","dueAmount":78750,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/dashboard_uploads/1623648478356pdf-textracted.json","textTractStatus":null,"filePath":"","imageFilePath":null,"invCreatedDate":"2021-06-14T13:23:59.000Z","orderNumber":"341742","success":0,"textractFailed":0,"manualExtractFailed":null,"extractEngineFailed":0,"status":"Pending","invoiceType":"Manual","actionBy":null,"actionDate":null,"name":"Corning Tropel Corporation","invoiceDate":"2021-06-28T18:30:00.000Z","supplierSite":"60 O\'Connor Roa","taxNumber":"","bankAccount":"914032-0122","sortCode":"736198273","swift":"","iban":"","supplierAddress2":"60 O\'Connor Road","city":"Fairport","state":"NY","postalCode":"14450","country":"US","supplierId":"48","supplierAddress":"60 O\'Connor Road","invoiceCurrency":"USD","invoiceAmount":78750,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":null,"phoneNumber":null,"mntName":"Jun","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Valid","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"302 0033677\\",\\"Suppliername\\":\\"Corning Tropel Corporation\\",\\"PoNumber\\":\\"341742\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Valid\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-06-28T12:11:43.000Z","requestId":null,"supplierCompanyName":"Soft System"}]}}}', '2021-07-01 16:15:20'),
	(40, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":72,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":72,"invoiceNumber":"125881","senderEmail":"testing9001@mailinator.com","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"testing9002@mailinator.com","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/mailinator/testing9001_mailinator/1624868661279pdf-textracted.json","textTractStatus":null,"filePath":"","imageFilePath":null,"invCreatedDate":"2021-07-01T11:04:54.000Z","orderNumber":"144805","success":0,"textractFailed":0,"manualExtractFailed":null,"extractEngineFailed":0,"status":"Approved","invoiceType":"Manual","actionBy":null,"actionDate":null,"name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"126 Hawkensen","taxNumber":"987456765","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"Dr. Rumney","city":"Acworth","state":"NH","postalCode":"03601","country":"US","supplierId":"23","supplierAddress":"126 Hawkensen","invoiceCurrency":"USD","invoiceAmount":48.68,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":null,"phoneNumber":null,"mntName":"Jul","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Valid","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"125881\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Valid\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-07-01T11:04:58.000Z","requestId":null,"supplierCompanyName":null}]}}}', '2021-07-01 16:35:25'),
	(41, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":1,"invoiceId":72,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":72,"invoiceNumber":"125881","senderEmail":"murukeshs@apptomate.co","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"testing9002@mailinator.com","dueAmount":48.68,"textractJson":"https://inbox-ezcloud123.s3.amazonaws.com/mailinator/testing9001_mailinator/1624868661279pdf-textracted.json","textTractStatus":null,"filePath":"","imageFilePath":null,"invCreatedDate":"2021-07-01T11:04:54.000Z","orderNumber":"144805","success":0,"textractFailed":0,"manualExtractFailed":null,"extractEngineFailed":0,"status":"Approved","invoiceType":"Manual","actionBy":null,"actionDate":null,"name":"Stonewall Cable, Inc.","invoiceDate":"2020-09-27T18:30:00.000Z","supplierSite":"126 Hawkensen","taxNumber":"987456765","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"Dr. Rumney","city":"Acworth","state":"NH","postalCode":"03601","country":"US","supplierId":"23","supplierAddress":"126 Hawkensen","invoiceCurrency":"USD","invoiceAmount":48.68,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":null,"phoneNumber":null,"mntName":"Jul","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":null,"teamId":null,"autoApproval":null,"teamCreatedDate":null,"teamType":null,"companyLogo":null,"companyName":null,"teamCreatedBy":null,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Extract","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"INVOICE","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Valid","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"125881\\",\\"Suppliername\\":\\"Stonewall Cable, Inc.\\",\\"PoNumber\\":\\"144805\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Valid\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-07-01T11:04:58.000Z","requestId":null,"supplierCompanyName":"Soft System"}]}}}', '2021-07-01 16:38:31'),
	(42, 'validationsInvoice', '{"Error":"getaddrinfo ENOTFOUND ezcloudsaas123dev01-ida64xtates0-ia.integration.ocp.oraclecloud.com","RequestData":{"invoiceNumber":"inv0999","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":90,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"0944","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"murukeshs@apptomate.co","status":"Pending","name":"murukesh","phoneNumber":"8870240610","invoiceDate":null,"invoiceDescription":"","documentType":"","invoiceAmount":5884,"taxTotal":null,"invoiceCurrency":"USD","imageFilePath":"","source":"Message Broker","action":"Insert","uploadBy":"Supplier","invoiceType":"Extract","ackEmail":"murukeshhh@gmail.com","ackRole":"Supplier","invoiceData":{"data":[{"invoiceNumber":"inv0999","orderNumber":"0944","name":"murukesh"}]},"firstName":"supplier","companyName":"Soft System","supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"getaddrinfo ENOTFOUND ezcloudsaas123dev01-ida64xtates0-ia.integration.ocp.oraclecloud.com"}}', '2021-07-16 17:35:43'),
	(43, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":54,"invoiceId":79,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":79,"invoiceNumber":"inv0999","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"murukeshs@apptomate.co","dueAmount":90,"textractJson":"","textTractStatus":1,"filePath":"","imageFilePath":"","invCreatedDate":"2021-07-16T12:08:35.000Z","orderNumber":"0944","success":1,"textractFailed":1,"manualExtractFailed":null,"extractEngineFailed":1,"status":"Pending","invoiceType":"Message Broker","actionBy":null,"actionDate":null,"name":"shawn.hummer","invoiceDate":null,"supplierSite":"132, My Street,","taxNumber":"","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"","city":"LAUREL","state":"MD","postalCode":"20723","country":"US","supplierId":"18","supplierAddress":"132, My Street,USA","invoiceCurrency":"USD","invoiceAmount":5884,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"","phoneNumber":"8870240610","mntName":"Jul","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"murukeshs@apptomate.co","teamId":39,"autoApproval":0,"teamCreatedDate":"2021-07-02T07:27:12.000Z","teamType":"Created By Admin","companyLogo":null,"companyName":"Apple Tech","teamCreatedBy":1,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Manual","phoneNumberTR":"Extract","supplierSiteTR":"Manual","taxNumberTR":"Manual","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Manual","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Doesn\'t exist in ERP","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"inv0999\\",\\"Suppliername\\":\\"shawn.hummer\\",\\"PoNumber\\":\\"0944\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Doesn\'t exist in ERP\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-07-20T09:36:44.000Z","requestId":null,"supplierCompanyName":"Soft System"}]}}}', '2021-07-20 15:11:33'),
	(44, 'validationsInvoice', '{"Error":"Request failed with status code 400","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshs@apptomate.co","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"7748383","invoiceDate":"2021-09-08T18:30:00.000Z","invoiceDescription":"desc","documentType":"Invoice","invoiceAmount":100,"taxTotal":10,"invoiceCurrency":"USD","imageFilePath":"","source":"Manual","action":"","uploadBy":"","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 400"}}', '2021-09-07 22:19:10'),
	(45, 'validationsInvoice', '{"Error":"Request failed with status code 400","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 400"}}', '2021-09-08 18:58:44'),
	(46, 'validationsInvoice', '{"Error":"Request failed with status code 500","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 500"}}', '2021-09-08 19:10:19'),
	(47, 'validationsInvoice', '{"Error":"connect ECONNREFUSED 34.204.91.155:8080","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"connect ECONNREFUSED 34.204.91.155:8080"}}', '2021-09-08 19:21:18'),
	(48, 'validationsInvoice', '{"Error":"Invalid value \\"undefined\\" for header \\"subscriberId\\"","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Invalid value \\"undefined\\" for header \\"subscriberId\\""}}', '2021-09-11 11:56:11'),
	(49, 'validationsInvoice', '{"Error":"Request failed with status code 500","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 500"}}', '2021-09-11 11:58:49'),
	(50, 'validationsInvoice', '{"Error":"Request failed with status code 500","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 500"}}', '2021-09-11 12:28:32'),
	(51, 'validationsInvoice', '{"Error":"Request failed with status code 500","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 500"}}', '2021-09-11 12:43:08'),
	(52, 'validationsInvoice', '{"Error":"Request failed with status code 500","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 500"}}', '2021-09-11 12:45:35'),
	(53, 'lookupService', '{"Error":{"message":"Request failed with status code 400","status":"Error"},"RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"invoiceStatus":"Valid","invoicePOStatus":"Valid","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"1601\\",\\"Suppliername\\":\\"shawn.hummer\\",\\"PoNumber\\":\\"2521\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Valid\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","lookupData":{"data":[{"supplier":"shawn.hummer","PO number":"2521"}]}}}', '2021-09-11 12:55:46'),
	(54, 'validationsInvoice', '{"Error":"Request failed with status code 500","RequestData":{"invoiceNumber":"1601","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"2521","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummer","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"Manual","action":"string","uploadBy":"string","invoiceType":"Extract","teamId":3,"invoiceData":{"data":[{"invoiceNumber":"1601","orderNumber":"2521","name":"shawn.hummer"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 500"}}', '2021-09-11 13:20:38'),
	(55, 'validationsInvoice', '{"Error":"Request failed with status code 404","RequestData":{"invoiceNumber":"160133","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueAmount":null,"textractJson":"","filepath":"","textTractStatus":true,"orderNumber":"252133","success":true,"textractFailed":true,"extractEngineFailed":true,"receiverEmail":"smith@apptomate.co","status":"Pending","name":"shawn.hummr","phoneNumber":"","invoiceDate":null,"invoiceDescription":"string","documentType":"string","invoiceAmount":null,"taxTotal":null,"invoiceCurrency":"string","imageFilePath":"string","source":"string","action":"string","uploadBy":"string","invoiceId":105,"invoiceData":{"data":[{"invoiceNumber":"160133","orderNumber":"252133","name":"shawn.hummr"}]},"supplierStatus":"Fail","invoicePOStatus":"Fail","invoiceStatus":"Fail","validationResponse":"Request failed with status code 404"}}', '2021-09-11 14:38:20'),
	(56, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":2,"invoiceId":105,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":105,"invoiceNumber":"160133","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"smith@apptomate.co","dueAmount":null,"textractJson":"","textTractStatus":1,"filePath":null,"imageFilePath":"string","invCreatedDate":"2021-09-11T07:50:52.000Z","orderNumber":"252133","success":1,"textractFailed":1,"manualExtractFailed":null,"extractEngineFailed":1,"status":"Pending","invoiceType":null,"actionBy":null,"actionDate":null,"name":"shawn.hummer","invoiceDate":null,"supplierSite":"132, My Street,","taxNumber":"","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"","city":"LAUREL","state":"MD","postalCode":"20723","country":"US","supplierId":"18","supplierAddress":"132, My Street,USA","invoiceCurrency":"string","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"string","phoneNumber":"","mntName":"Sep","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"smith@apptomate.co","teamId":3,"autoApproval":20,"teamCreatedDate":"2020-12-16T10:12:08.000Z","teamType":"Created By Admin","companyLogo":"logo1.png","companyName":"Digi","teamCreatedBy":1,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Manual","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"string","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Doesn\'t exist in ERP","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"160133\\",\\"Suppliername\\":\\"shawn.hummer\\",\\"PoNumber\\":\\"252133\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Doesn\'t exist in ERP\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-09-11T09:21:03.000Z","requestId":null,"supplierCompanyName":null,"actionByRole":null}]}}}', '2021-09-11 15:01:10'),
	(57, 'approveInvoice', '{"Error":{"message":"Request failed with status code 500","status":"Error"},"RequestData":{"userId":2,"invoiceId":105,"status":"Approved","invoice":{"status":"Success","data":[{"invoiceId":105,"invoiceNumber":"160133","senderEmail":"murukeshhh@gmail.com","dueDate":null,"dueDateYYYMMDD":null,"receiverEmail":"smith@apptomate.co","dueAmount":null,"textractJson":"","textTractStatus":1,"filePath":null,"imageFilePath":"string","invCreatedDate":"2021-09-11T07:50:52.000Z","orderNumber":"252133","success":1,"textractFailed":1,"manualExtractFailed":null,"extractEngineFailed":1,"status":"Pending","invoiceType":null,"actionBy":null,"actionDate":null,"name":"shawn.hummer","invoiceDate":null,"supplierSite":"132, My Street,","taxNumber":"","bankAccount":"","sortCode":"","swift":"","iban":"","supplierAddress2":"","city":"LAUREL","state":"MD","postalCode":"20723","country":"US","supplierId":"18","supplierAddress":"132, My Street,USA","invoiceCurrency":"string","invoiceAmount":null,"paidAmount":null,"taxTotal":null,"totalAmount":null,"invoiceDescription":"string","phoneNumber":"","mntName":"Sep","invoiceYear":2021,"invoiceLine":null,"invoiceSenderEmail":"smith@apptomate.co","teamId":3,"autoApproval":20,"teamCreatedDate":"2020-12-16T10:12:08.000Z","teamType":"Created By Admin","companyLogo":"logo1.png","companyName":"Digi","teamCreatedBy":1,"lockId":null,"lockedDate":null,"lockedBy":null,"lockedUserName":null,"lockedEmail":null,"invoiceNumberTR":"Extract","dueDateTR":"Extract","dueAmountTR":"Extract","orderNumberTR":"Extract","invoiceDateTR":"Extract","nameTR":"Manual","phoneNumberTR":"Extract","supplierSiteTR":"Extract","taxNumberTR":"Extract","bankAccountTR":"Extract","sortCodeTR":"Extract","swiftTR":"Extract","ibanTR":"Extract","supplierAddressTR":"Extract","invoiceCurrencyTR":"Extract","invoiceAmountTR":"Extract","documentType":"string","documentTypeTR":"Extract","paidAmountTR":"Extract","taxTotalTR":"Extract","invoiceDescriptionTR":"Extract","totalAmountTR":"Extract","invoiceStatus":"Valid","invoicePOStatus":"Doesn\'t exist in ERP","supplierStatus":"Valid","validationResponse":"{\\"data\\":[{\\"Invoice\\":\\"160133\\",\\"Suppliername\\":\\"shawn.hummer\\",\\"PoNumber\\":\\"252133\\",\\"validateInvoiceStatus\\":\\"Valid\\",\\"validateInvoicePOStatus\\":\\"Doesn\'t exist in ERP\\",\\"validateSupplierStatus\\":\\"Valid\\"}]}","validationRequestDate":"2021-09-11T09:21:03.000Z","requestId":null,"supplierCompanyName":null,"actionByRole":null}]}}}', '2021-09-11 15:02:35');
/*!40000 ALTER TABLE `tbllog` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblotp
CREATE TABLE IF NOT EXISTS `tblotp` (
  `otpId` int(11) NOT NULL AUTO_INCREMENT,
  `otpType` varchar(20) DEFAULT NULL,
  `otpValue` varchar(10) DEFAULT NULL,
  `otpTo` varchar(50) DEFAULT NULL,
  `countryCode` varchar(10) DEFAULT NULL,
  `createdDate` datetime DEFAULT NULL,
  `isVerified` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`otpId`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblotp: ~46 rows (approximately)
/*!40000 ALTER TABLE `tblotp` DISABLE KEYS */;
INSERT IGNORE INTO `tblotp` (`otpId`, `otpType`, `otpValue`, `otpTo`, `countryCode`, `createdDate`, `isVerified`) VALUES
	(1, 'Phone', 'jdlu1p', '8667749365', '+91', '2021-02-01 14:01:54', 1),
	(2, 'Phone', '127257', '8667749365', '+91', '2021-02-01 14:33:49', 1),
	(3, 'Phone', '364582', '8667749365', '+91', '2021-02-01 15:00:52', 0),
	(4, 'Phone', '803866', '8667749365', '+91', '2021-02-01 15:03:32', 0),
	(5, 'Phone', '438586', '8667749365', '+91', '2021-02-01 15:05:16', 0),
	(6, 'Phone', '650477', '8667749365', '+91', '2021-02-01 15:08:14', 0),
	(7, 'Phone', '265174', '8667749365', '+91', '2021-02-01 15:56:49', 0),
	(8, 'Phone', '433831', '8667749365', '+91', '2021-02-01 15:59:21', 0),
	(9, 'Phone', '681457', '8667749365', '+91', '2021-02-01 16:08:00', 0),
	(10, 'Phone', '211378', '8667749365', '+91', '2021-02-01 16:11:05', 0),
	(11, 'Phone', '405657', '8667749365', '+91', '2021-02-01 16:11:31', 0),
	(12, 'Phone', '575773', '8870240610', '+91', '2021-02-01 16:12:22', 1),
	(13, 'Phone', '305715', '8870240610', '+91', '2021-02-01 19:32:00', 1),
	(14, 'Phone', '757666', '8870240610', '+91', '2021-02-15 23:05:18', 1),
	(15, 'Phone', '544858', '8870240610', '+91', '2021-03-02 17:45:06', 1),
	(16, 'Phone', '674687', '8870240610', '+91', '2021-03-24 16:14:34', 0),
	(17, 'Phone', '418238', '8870240610', '+91', '2021-03-24 16:16:44', 0),
	(18, 'Phone', '334041', '8870240610', '+91', '2021-03-24 16:17:32', 0),
	(19, 'Phone', '020125', '8870240610', '+91', '2021-03-24 16:18:06', 0),
	(20, 'Phone', '802060', '8870240610', '+91', '2021-03-24 16:18:40', 0),
	(21, 'Phone', '035036', '8870240610', '+91', '2021-03-24 16:28:32', 0),
	(22, 'Phone', '364350', '8870240610', '+91', '2021-03-24 16:29:48', 0),
	(23, 'Phone', '742625', '8870240610', '+91', '2021-03-24 16:40:07', 0),
	(24, 'Phone', '756276', '8870240610', '+91', '2021-03-24 16:43:17', 0),
	(25, 'Phone', '188321', '8870240610', '+91', '2021-03-24 16:44:55', 0),
	(26, 'Phone', '382378', '8870240610', '+91', '2021-03-24 16:47:44', 0),
	(27, 'Phone', '468125', '8870240610', '+91', '2021-03-24 16:48:49', 0),
	(28, 'Phone', '644270', '8870240610', '+91', '2021-03-24 16:50:01', 0),
	(29, 'Phone', '848571', '8667749365', '+91', '2021-03-24 16:51:59', 0),
	(30, 'Phone', '326401', '8667749365', '+91', '2021-03-24 16:52:04', 0),
	(31, 'Phone', '528244', '8667749365', '+91', '2021-03-24 17:10:09', 0),
	(32, 'Phone', '230766', '8667749365', '+91', '2021-03-24 20:18:44', 0),
	(33, 'Phone', '112827', '8667749365', '+91', '2021-03-24 20:23:44', 0),
	(34, 'Phone', '456572', '8667749365', '+91', '2021-03-24 20:30:14', 0),
	(35, 'Phone', '874745', '8667749365', '+91', '2021-03-24 20:37:23', 0),
	(36, 'Phone', '678046', '8667749365', '+91', '2021-03-24 20:39:34', 0),
	(37, 'Phone', '665326', '8667749365', '+91', '2021-03-24 23:05:34', 0),
	(38, 'Phone', '705128', '8667749365', '+91', '2021-03-24 23:25:26', 0),
	(39, 'Phone', '228775', '8667749365', '+91', '2021-03-24 23:27:27', 0),
	(40, 'Phone', '518385', '8667749365', '+91', '2021-03-24 23:32:53', 0),
	(41, 'Phone', '561066', '8667749365', '+91', '2021-03-30 00:05:28', 0),
	(42, 'Phone', '026558', '8870240610', '+91', '2021-03-30 00:06:04', 0),
	(43, 'Phone', '186227', '9894625830', '+91', '2021-03-30 00:07:56', 0),
	(44, 'Phone', '804355', '9894625830', '+91', '2021-03-30 00:12:35', 0),
	(45, 'Phone', '101501', '9894625830', '+91', '2021-03-30 00:18:19', 0),
	(46, 'Phone', '040402', '9894625830', '+91', '2021-03-30 00:19:03', 0);
/*!40000 ALTER TABLE `tblotp` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblplan
CREATE TABLE IF NOT EXISTS `tblplan` (
  `planId` int(11) NOT NULL AUTO_INCREMENT,
  `planName` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`planId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblplan: ~2 rows (approximately)
/*!40000 ALTER TABLE `tblplan` DISABLE KEYS */;
INSERT IGNORE INTO `tblplan` (`planId`, `planName`) VALUES
	(1, 'Free'),
	(2, 'Premium');
/*!40000 ALTER TABLE `tblplan` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblsupplierrequest
CREATE TABLE IF NOT EXISTS `tblsupplierrequest` (
  `requestId` int(11) NOT NULL AUTO_INCREMENT,
  `teamId` int(11) DEFAULT NULL,
  `requestedBy` int(11) DEFAULT NULL,
  `supplierEmail` varchar(50) DEFAULT NULL,
  `requestStatus` varchar(25) DEFAULT NULL,
  `requestDate` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`requestId`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblsupplierrequest: ~8 rows (approximately)
/*!40000 ALTER TABLE `tblsupplierrequest` DISABLE KEYS */;
INSERT IGNORE INTO `tblsupplierrequest` (`requestId`, `teamId`, `requestedBy`, `supplierEmail`, `requestStatus`, `requestDate`, `isDeleted`) VALUES
	(1, 1, 1, 'ram1@gmil.com', 'Accepted', '2021-02-18 15:34:24', 0),
	(2, 1, 1, 'ramm@gmail.com', 'Deactivated', '2021-02-18 15:51:31', 0),
	(3, 1, 4, 'ram@gmil1.com', 'DeActivate', '2021-03-13 14:04:46', 0),
	(4, 1, 1, 'hari@gmail.com', 'Pending', '2021-03-16 15:21:47', 0),
	(13, 1, 5, 'tblsupplierrequest', 'Pending', '2021-04-19 14:26:59', 0),
	(15, 1, 5, 'murukeshhh@gmail.com', 'Pending', '2021-04-22 12:11:09', 0),
	(22, 30, 40, 'murukeshhh@gmail.com', 'DeActivate', '2021-07-01 19:13:49', 0),
	(23, 3, 1, 'murukeshhh@gmail.com', 'Pending', '2021-08-18 13:06:07', 0);
/*!40000 ALTER TABLE `tblsupplierrequest` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tbltageduser
CREATE TABLE IF NOT EXISTS `tbltageduser` (
  `commentId` int(11) DEFAULT NULL,
  `userId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tbltageduser: ~4 rows (approximately)
/*!40000 ALTER TABLE `tbltageduser` DISABLE KEYS */;
INSERT IGNORE INTO `tbltageduser` (`commentId`, `userId`) VALUES
	(3, 53),
	(3, 54),
	(4, 50),
	(4, 51);
/*!40000 ALTER TABLE `tbltageduser` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblteam
CREATE TABLE IF NOT EXISTS `tblteam` (
  `teamId` int(11) NOT NULL AUTO_INCREMENT,
  `invoiceSenderEmail` varchar(50) DEFAULT NULL,
  `autoApproval` decimal(17,2) DEFAULT NULL,
  `createdDate` datetime DEFAULT NULL,
  `teamType` varchar(25) DEFAULT NULL,
  `companyLogo` varchar(1000) DEFAULT NULL,
  `companyName` varchar(100) DEFAULT NULL,
  `planId` int(11) DEFAULT NULL,
  `createdBy` int(11) DEFAULT NULL,
  `entityType` varchar(30) DEFAULT NULL,
  `expiryDate` date DEFAULT NULL,
  PRIMARY KEY (`teamId`),
  UNIQUE KEY `invoiceSenderEmail` (`invoiceSenderEmail`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblteam: ~25 rows (approximately)
/*!40000 ALTER TABLE `tblteam` DISABLE KEYS */;
INSERT IGNORE INTO `tblteam` (`teamId`, `invoiceSenderEmail`, `autoApproval`, `createdDate`, `teamType`, `companyLogo`, `companyName`, `planId`, `createdBy`, `entityType`, `expiryDate`) VALUES
	(1, 'murukeshs1@apptomate.co', 200.00, '2020-10-01 14:53:09', NULL, 'https://logoez.s3.amazonaws.com/final-2-2_2021-03-02-08-25-14_2021-03-02-09-49-04.png', 'Apptomate Soft', NULL, NULL, 'Customer', '2022-04-15'),
	(3, 'smith@apptomate.co', 20.00, '2020-12-16 15:42:08', 'Created By Admin', 'logo1.png', 'Digi', 2, 1, 'Customer', '2021-04-15'),
	(4, 'paul@gmail.com', 20.00, '2020-12-16 15:51:52', 'Open Registration', 'logo.png', 'paul pvt', 1, NULL, 'Customer', '2021-04-15'),
	(5, 'string', 20.00, '2021-01-21 18:02:11', 'Open Registration', 'string', 'string', 0, NULL, 'Customer', '2021-04-15'),
	(6, 'fff', 20.00, '2021-01-23 15:34:31', 'Created By Admin', '', 'Apptomate@123', 1, 1, 'Customer', '2021-04-15'),
	(8, 'murukeshhh@gmail.com1', 20.00, '2021-01-23 15:38:14', 'Created By Admin', '', 'Apptomate@123', 1, 1, 'Customer', '2021-04-15'),
	(10, 'fff1', 20.00, '2021-01-28 16:55:33', 'Open Registration', '', 'Apptomate', 1, NULL, 'Customer', '2021-04-15'),
	(11, 'f44ff1', 20.00, '2021-01-28 17:03:30', 'Open Registration', '', 'Apptomate', 1, NULL, 'Customer', NULL),
	(12, 'f44f44f1', 20.00, '2021-01-28 17:10:28', 'Open Registration', '', 'Apptomate', 1, NULL, 'Customer', NULL),
	(13, 'murukeshhh@gmail.com2', 20.00, '2021-01-28 17:14:53', 'Open Registration', '', 'Apptomate', 1, NULL, 'Customer', NULL),
	(14, 'ram@gmil.com', 20.00, '2021-02-05 13:55:34', 'Open Registration', '', 'Ram Tech', NULL, NULL, 'Supplier', NULL),
	(15, 'ram@gmil1.com', 20.00, '2021-02-05 14:45:46', 'Open Registration', '', 'Ram Tech', NULL, NULL, 'Supplier', NULL),
	(16, 'ram1@gmil.com', 20.00, '2021-02-05 14:47:45', 'Open Registration', '', 'Ram Tech', NULL, NULL, 'Supplier', NULL),
	(19, 'kajas@apptomate.co', 20.00, '2021-03-24 11:53:52', 'Open Registration', '', 'Kaja trade', 1, NULL, 'Customer', NULL),
	(20, 'murukesh@apptomate.co', 20.00, '2021-04-05 19:18:30', 'Open Registration', '', 'Digital Soft', 0, NULL, 'Customer', NULL),
	(24, 'murukeshhhl@gmail.comdd', 20.00, '2021-04-08 18:24:23', 'Created By Admin', NULL, NULL, 2, NULL, 'Customer', NULL),
	(25, 'murukes@gmail.com', 0.00, '2021-04-15 18:05:31', 'Created By Admin', NULL, NULL, 2, NULL, 'Customer', '2021-04-19'),
	(26, 'muu@gmail.com', 0.00, '2021-04-15 18:11:53', 'Open Registration', '', 'test office', 1, NULL, 'Customer', NULL),
	(30, 'kumar@gmail.com', 0.00, '2021-04-19 15:24:06', 'Created By Admin', NULL, 'System soft', 2, 1, 'Customer', '2020-04-20'),
	(35, 'murukeshs2@apptomate.co', 0.00, '2021-07-01 14:08:31', 'Open Registration', '', 'Soft System', 1, NULL, 'Customer', NULL),
	(36, 'murukeshs3@apptomate.co', 0.00, '2021-07-01 14:11:00', 'Open Registration', '', 'Soft System', 1, NULL, 'Customer', NULL),
	(37, 'murukeshsa@apptomate.co', 0.00, '2021-07-01 14:16:34', 'Open Registration', '', 'Soft System', 1, NULL, 'Customer', NULL),
	(38, 'murukeshhh@gmail.comjj', 0.00, '2021-07-01 14:23:32', 'Open Registration', '', 'Soft System', 1, NULL, 'Supplier', NULL),
	(39, 'murukeshs@apptomate.co', 0.00, '2021-07-02 12:57:12', 'Created By Admin', NULL, 'Apple Tech', 2, 1, 'Customer', '2022-07-02'),
	(40, 'teamuser1@gmail.com', 0.00, '2021-07-21 16:17:32', 'Open Registration', '', 'User team 1', 1, NULL, 'Customer', NULL);
/*!40000 ALTER TABLE `tblteam` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tblteammembers
CREATE TABLE IF NOT EXISTS `tblteammembers` (
  `memberId` int(11) NOT NULL AUTO_INCREMENT,
  `teamId` int(11) DEFAULT NULL,
  `userId` int(11) DEFAULT NULL,
  PRIMARY KEY (`memberId`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tblteammembers: ~42 rows (approximately)
/*!40000 ALTER TABLE `tblteammembers` DISABLE KEYS */;
INSERT IGNORE INTO `tblteammembers` (`memberId`, `teamId`, `userId`) VALUES
	(1, 1, 4),
	(2, 1, 5),
	(3, 3, 7),
	(4, 4, 8),
	(5, NULL, 10),
	(6, 5, 11),
	(7, 6, 12),
	(8, 8, 14),
	(9, 4, 15),
	(10, 10, 17),
	(11, 11, 18),
	(12, 12, 19),
	(13, 13, 20),
	(14, NULL, 21),
	(15, 14, 22),
	(16, 15, 23),
	(17, 16, 24),
	(19, 19, 27),
	(20, 20, 28),
	(24, 24, 32),
	(25, NULL, 33),
	(26, NULL, 34),
	(27, 25, 35),
	(28, 26, 36),
	(29, 30, 40),
	(30, 31, 41),
	(31, 32, 42),
	(32, 33, 43),
	(33, 1, 44),
	(34, 1, 45),
	(35, 1, 46),
	(36, 34, 47),
	(37, 3, 48),
	(38, NULL, 49),
	(39, 35, 50),
	(40, 36, 51),
	(41, 37, 52),
	(43, 30, 54),
	(44, 39, 55),
	(45, 1, 56),
	(46, 40, 57),
	(47, 1, 58);
/*!40000 ALTER TABLE `tblteammembers` ENABLE KEYS */;

-- Dumping structure for table ezcloud.tbluser
CREATE TABLE IF NOT EXISTS `tbluser` (
  `userId` int(11) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(50) DEFAULT NULL,
  `lastName` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `password` varchar(500) DEFAULT NULL,
  `phoneNumber` varchar(50) DEFAULT NULL,
  `approvalAmountFrom` decimal(10,2) DEFAULT NULL,
  `approvalAmountTo` decimal(17,2) DEFAULT NULL,
  `profileLogo` varchar(1000) DEFAULT NULL,
  `createdBy` int(11) DEFAULT NULL,
  `createdDate` datetime DEFAULT NULL,
  `userRole` varchar(25) DEFAULT NULL,
  `isDefaultPassword` tinyint(1) DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT NULL,
  `hashKey` varchar(50) DEFAULT NULL,
  `isEmailVerified` tinyint(1) DEFAULT 1,
  `countryCode` varchar(10) DEFAULT NULL,
  `isPhoneVerified` tinyint(1) DEFAULT 0,
  `lastSignIn` datetime DEFAULT NULL,
  `lastSignOut` datetime DEFAULT NULL,
  `isActive` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`userId`),
  KEY `createdBy` (`createdBy`),
  CONSTRAINT `tbluser_ibfk_1` FOREIGN KEY (`createdBy`) REFERENCES `tbluser` (`userId`),
  CONSTRAINT `tbluser_ibfk_2` FOREIGN KEY (`createdBy`) REFERENCES `tbluser` (`userId`),
  CONSTRAINT `tbluser_ibfk_3` FOREIGN KEY (`createdBy`) REFERENCES `tbluser` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table ezcloud.tbluser: ~28 rows (approximately)
/*!40000 ALTER TABLE `tbluser` DISABLE KEYS */;
INSERT IGNORE INTO `tbluser` (`userId`, `firstName`, `lastName`, `email`, `password`, `phoneNumber`, `approvalAmountFrom`, `approvalAmountTo`, `profileLogo`, `createdBy`, `createdDate`, `userRole`, `isDefaultPassword`, `isDeleted`, `hashKey`, `isEmailVerified`, `countryCode`, `isPhoneVerified`, `lastSignIn`, `lastSignOut`, `isActive`) VALUES
	(1, 'murukesh', 'kumar', 'murukeshs1@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '8870240610', 1.00, 1000000.00, '', NULL, '2020-09-28 13:27:40', 'Super Admin', 0, 0, NULL, 1, '+91', 0, '2021-07-23 12:41:41', '2021-02-10 19:23:30', 0),
	(4, 'shawn', 'hummer', 'shawn.hummer@ezcloud.co', 'd8bc7127ee73223658bad29d9faa0032', '8667749365', 1.00, 2000.00, '', 1, '2020-10-01 14:53:09', 'Super Admin', 1, 0, NULL, 1, '+91', 0, '2021-07-02 12:56:35', NULL, 1),
	(5, 'test', 'user5', 'shawn.hummer@inspiredecm.com', 'c915b744a6000b6b2b9fbf204f1eefd6', '88702406100', 1.00, -1.00, 'logo.png', 4, '2020-10-01 14:56:47', 'Team Member', 1, 0, NULL, 1, '+91', 0, '2021-07-21 15:33:49', NULL, 1),
	(7, 'paul', 'smith', 'smith@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '980877666', 1.00, 200.00, 'logo1.png', 1, '2020-12-16 15:42:08', 'Admin', 1, 0, NULL, 1, NULL, 0, '2021-03-30 21:06:39', NULL, 1),
	(8, 'smith', 'paul', 'paul@gmail.com', 'e99545001372179a734b38d383d3ccdf', '9894625830', 1.00, 200.00, 'logo.png', NULL, '2020-12-16 15:51:52', 'Admin', 1, 0, NULL, 1, NULL, 0, '2021-04-15 15:10:22', NULL, 1),
	(9, 'super', 'admin 1', 'superadmin@gmail.com', 'c5b07183baa2863f49fc1c9372773199', '887887767', NULL, NULL, 'logo1.png', 1, '2020-12-16 16:03:02', 'Super Admin', 1, 0, NULL, 1, NULL, 0, NULL, NULL, 1),
	(10, 'murukesh', 'kumar', 'murukeshhh1@gmail.com', '02aebcfd16418a060f434d504d39110d', '8667749365', 10.00, 1000.00, '', 1, '2021-01-07 20:36:26', 'Team Member', 1, 0, NULL, 1, '+91', 1, NULL, NULL, 1),
	(11, 'string', 'string', 'string', '1c23179e8ec79f848b5f9b604bfbd789', 'string', 0.00, 0.00, 'string', NULL, '2021-01-21 18:02:11', 'Admin', 0, 0, NULL, 1, NULL, 0, '2021-07-23 15:29:36', NULL, 1),
	(21, 'user1', 'user2', 'murukeshs@apptomate.co1', 'e99545001372179a734b38d383d3ccdf', '8870240617', 100.00, 2000.00, '', 1, '2021-02-01 19:59:45', 'Team Member', 1, 0, NULL, 1, '+91', 0, '2021-09-02 14:37:50', NULL, 1),
	(22, 'ram', 'kumar', 'ram@gmil.com', 'e99545001372179a734b38d383d3ccdf', '8870240619', 0.00, 0.00, '', NULL, '2021-02-05 13:55:34', 'Supplier', 0, 0, '7f4ed8f4faafd17dd907442e97ff973e', 0, '+91', 0, NULL, NULL, 1),
	(23, 'ram', 'kumar', 'ram@gmil1.com', 'e99545001372179a734b38d383d3ccdf', '8870240629', 0.00, 0.00, '', NULL, '2021-02-05 14:45:46', 'Supplier', 0, 0, '6b369dc6054f0271c19b040414488c7d', 0, '+91', 0, NULL, NULL, 1),
	(24, 'ram', 'kumar', 'ram1@gmil.com', 'e99545001372179a734b38d383d3ccdf', '8870240630', 0.00, 0.00, '', NULL, '2021-02-05 14:47:45', 'Supplier', 0, 0, NULL, 1, '+91', 0, '2021-02-23 13:51:51', NULL, 1),
	(27, 'kaja', 'Naju', 'kajas@apptomate.co', '04354f548bedc8324dbdfb3e8d9c6dcf', '848847733', 0.00, 0.00, '', NULL, '2021-03-24 11:53:52', 'Admin', 1, 0, 'd87b6be2fbef672b36e7e28b6ba6e540', 0, '91', 0, NULL, NULL, 1),
	(28, 'murukesh', 'kumar', 'murukesh@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '8870234059', 0.00, 10000.00, '', NULL, '2021-04-05 19:18:30', 'Admin', 0, 0, '20a6fe31bdf63ca5c53b88b7ca64e9ae', 0, '+91', 0, NULL, NULL, 1),
	(35, 'murukesh', NULL, 'murukes@gmail.com', 'e99545001372179a734b38d383d3ccdf', NULL, NULL, NULL, NULL, NULL, '2021-04-15 18:05:31', 'Admin', 1, 0, NULL, 0, NULL, 0, '2021-04-19 13:47:07', NULL, 1),
	(36, 'sa', 'mu', 'muu@gmail.com', 'e99545001372179a734b38d383d3ccdf', '858893', 0.00, 0.00, '', NULL, '2021-04-15 18:11:53', 'Admin', 0, 0, '2f0983934cebf5e03caf63fd8a23a8f5', 0, '', 0, NULL, NULL, 1),
	(40, 'kumar', 'murukesh', 'kumar@gmail.com', '7bbf700c08f49878024d2ab51dc27119', NULL, NULL, NULL, NULL, 1, '2021-04-19 15:24:06', 'Admin', 1, 0, NULL, 1, NULL, 0, NULL, NULL, 1),
	(48, 'team_user1', '', 'team_user1@gmail.com', '62fec6fca8f591dd25b04eda2df91e57', '88703848484', 0.00, -1.00, '', 7, '2021-05-24 16:28:42', 'Team Member', 1, 0, NULL, 1, '+91', 0, NULL, NULL, 1),
	(49, 'Gayathri', 'T', 'gayathris@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '57483833', 0.00, 11110.00, '', 1, '2021-05-30 16:03:17', 'Team Member', 1, 0, NULL, 1, '+91', 0, NULL, NULL, 1),
	(50, 'murukesh 50', 'kumar', 'murukeshs2@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '8870240628', 0.00, 0.00, '', NULL, '2021-07-01 14:08:31', 'Admin', 0, 0, '5210b5a2b565fe8f4eb5d4de7484f510', 0, '+91', 0, NULL, NULL, 1),
	(51, 'murukesh 51', 'kumar', 'murukeshs3@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '88702406208', 0.00, 0.00, '', NULL, '2021-07-01 14:11:00', 'Admin', 0, 0, 'b891105e7b900b47edeb7a5800a14075', 0, '+91', 0, NULL, NULL, 1),
	(52, 'murukesh', 'kumar', 'murukeshsa@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '88702406218', 0.00, 0.00, '', NULL, '2021-07-01 14:16:34', 'Admin', 0, 0, '5d219f948e0cee9a2af111ecd1ca2d9b', 0, '+91', 0, NULL, NULL, 1),
	(53, 'murukesh 53', 'kumar', 'murukeshs4@apptomate.co', 'e99545001372179a734b38d383d3ccdf', '88702406028', 0.00, 0.00, '', NULL, '2021-07-01 14:23:32', 'Supplier', 0, 0, '64949114e5998050bbb8cc320a6721bd', 1, '+91', 0, '2021-07-02 12:44:38', NULL, 1),
	(54, 'supplier 54', 'murukesh', 'murukeshhh@gmail.com', 'e99545001372179a734b38d383d3ccdf', '58859393', 0.00, 1000.00, '', 40, '2021-07-01 22:34:11', 'Supplier', 1, 0, NULL, 1, '44', 0, '2021-07-23 15:44:37', NULL, 1),
	(55, 'murukesh', NULL, 'murukeshs@apptomate.co', '3c2db7ba677ce7d1ff76eb86aa5a4213', NULL, NULL, NULL, NULL, 1, '2021-07-02 12:57:12', 'Admin', 1, 0, NULL, 1, NULL, 0, '2021-07-19 13:27:45', NULL, 1),
	(56, 'test', 'user5', 'teamuser1@gmail.com0', '0e6e82e7f8f3705c869dfe65b1caa3dd', '885589393', 0.00, 10000.00, '', 4, '2021-07-21 15:36:51', 'Team Member', 1, 0, NULL, 1, '+91', 0, NULL, NULL, 1),
	(57, 'us1', 'ls1', 'teamuser1@gmail.com', 'e99545001372179a734b38d383d3ccdf', '', 0.00, 0.00, '', NULL, '2021-07-21 16:17:32', 'Admin', 0, 0, 'c63b0b298774b7752ba6b27f5da6f82d', 0, '', 0, NULL, NULL, 1),
	(58, 'string', 'string', 'string@gmail.com', '1c23179e8ec79f848b5f9b604bfbd789', 'uuii', 0.00, 1110.00, 'string', 4, '2021-07-23 12:43:27', 'Team Member', 1, 0, NULL, 1, 'string', 0, NULL, NULL, 1);
/*!40000 ALTER TABLE `tbluser` ENABLE KEYS */;

-- Dumping structure for view ezcloud.vwgetaudit
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwgetaudit` (
	`logId` INT(11) NOT NULL,
	`invoiceId` INT(11) NULL,
	`comment` VARCHAR(250) NULL COLLATE 'utf8mb4_general_ci',
	`actionDate` DATETIME NULL,
	`actionBy` INT(11) NULL,
	`actionName` VARCHAR(101) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view ezcloud.vwgetcomment
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwgetcomment` (
	`commentId` INT(11) NOT NULL,
	`comment` LONGTEXT NULL COLLATE 'utf8mb4_general_ci',
	`postDate` DATETIME NULL,
	`postedBy` INT(11) NULL,
	`invoiceId` INT(11) NULL,
	`invoiceNumber` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`postedByName` VARCHAR(101) NULL COLLATE 'utf8mb4_general_ci',
	`postedByLogo` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`postedByEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`tagByName` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci',
	`tagBy` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view ezcloud.vwgetentityuser
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwgetentityuser` (
	`email` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`teamId` INT(11) NULL,
	`companyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci',
	`entityType` VARCHAR(30) NULL COLLATE 'utf8mb4_general_ci',
	`firstName` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`lastName` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view ezcloud.vwgetinvoicedetails
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwgetinvoicedetails` (
	`invoiceId` INT(11) NOT NULL,
	`invoiceNumber` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`senderEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`dueDate` DATE NULL,
	`dueDateYYYMMDD` DATE NULL,
	`receiverEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`dueAmount` DECIMAL(10,2) NULL,
	`textractJson` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`textTractStatus` TINYINT(1) NULL,
	`filePath` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`imageFilePath` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`invCreatedDate` DATETIME NULL,
	`orderNumber` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`success` TINYINT(4) NULL,
	`textractFailed` TINYINT(4) NULL,
	`manualExtractFailed` TINYINT(4) NULL,
	`extractEngineFailed` TINYINT(1) NULL,
	`status` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceType` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`actionBy` INT(11) NULL,
	`actionDate` DATETIME NULL,
	`name` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceDate` DATETIME NULL,
	`supplierSite` VARCHAR(250) NULL COLLATE 'utf8mb4_general_ci',
	`taxNumber` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`bankAccount` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`sortCode` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`swift` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`iban` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`supplierAddress2` VARCHAR(250) NULL COLLATE 'utf8mb4_general_ci',
	`city` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`state` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`postalCode` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`country` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`supplierId` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`supplierAddress` VARCHAR(500) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceCurrency` VARCHAR(10) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceAmount` DECIMAL(17,2) NULL,
	`paidAmount` DECIMAL(17,2) NULL,
	`taxTotal` DECIMAL(17,2) NULL,
	`totalAmount` DECIMAL(17,2) NULL,
	`invoiceDescription` VARCHAR(500) NULL COLLATE 'utf8mb4_general_ci',
	`phoneNumber` VARCHAR(30) NULL COLLATE 'utf8mb4_general_ci',
	`mntName` VARCHAR(32) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceYear` INT(4) NULL,
	`invoiceLine` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci',
	`invoiceSenderEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`teamId` INT(11) NULL,
	`autoApproval` DECIMAL(17,2) NULL,
	`teamCreatedDate` DATETIME NULL,
	`teamType` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`companyLogo` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`companyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci',
	`teamCreatedBy` INT(11) NULL,
	`lockId` INT(11) NULL,
	`lockedDate` DATETIME NULL,
	`lockedBy` INT(11) NULL,
	`lockedUserName` VARCHAR(101) NULL COLLATE 'utf8mb4_general_ci',
	`lockedEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`dueDateTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`dueAmountTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`orderNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceDateTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`nameTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`phoneNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`supplierSiteTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`taxNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`bankAccountTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`sortCodeTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`swiftTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`ibanTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`supplierAddressTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceCurrencyTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceAmountTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`documentType` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`documentTypeTR` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`paidAmountTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`taxTotalTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceDescriptionTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`totalAmountTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceStatus` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoicePOStatus` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`supplierStatus` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`validationResponse` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`validationRequestDate` DATETIME NULL,
	`requestId` INT(11) NULL,
	`supplierCompanyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci',
	`actionByRole` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view ezcloud.vwgetinvoicereport
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwgetinvoicereport` (
	`invoiceId` INT(11) NOT NULL,
	`invoiceNumber` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`senderEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`dueDate` DATE NULL,
	`dueDateYYYMMDD` DATE NULL,
	`receiverEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`dueAmount` DECIMAL(10,2) NULL,
	`textractJson` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`textTractStatus` TINYINT(1) NULL,
	`filePath` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`imageFilePath` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`invCreatedDate` DATETIME NULL,
	`orderNumber` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`success` TINYINT(4) NULL,
	`textractFailed` TINYINT(4) NULL,
	`manualExtractFailed` TINYINT(4) NULL,
	`extractEngineFailed` TINYINT(1) NULL,
	`status` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceType` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`actionBy` INT(11) NULL,
	`actionDate` DATETIME NULL,
	`name` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceDate` DATETIME NULL,
	`supplierSite` VARCHAR(250) NULL COLLATE 'utf8mb4_general_ci',
	`taxNumber` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`bankAccount` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`sortCode` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`swift` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`iban` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`supplierAddress2` VARCHAR(250) NULL COLLATE 'utf8mb4_general_ci',
	`city` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`state` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`postalCode` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`country` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`supplierId` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`supplierAddress` VARCHAR(500) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceCurrency` VARCHAR(10) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceAmount` DECIMAL(17,2) NULL,
	`paidAmount` DECIMAL(17,2) NULL,
	`taxTotal` DECIMAL(17,2) NULL,
	`totalAmount` DECIMAL(17,2) NULL,
	`invoiceDescription` VARCHAR(500) NULL COLLATE 'utf8mb4_general_ci',
	`phoneNumber` VARCHAR(30) NULL COLLATE 'utf8mb4_general_ci',
	`mntName` VARCHAR(32) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceYear` INT(4) NULL,
	`invoiceLine` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci',
	`invoiceSenderEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`teamId` INT(11) NULL,
	`autoApproval` DECIMAL(17,2) NULL,
	`teamCreatedDate` DATETIME NULL,
	`teamType` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`companyLogo` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`companyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci',
	`teamCreatedBy` INT(11) NULL,
	`lockId` INT(11) NULL,
	`lockedDate` DATETIME NULL,
	`lockedBy` INT(11) NULL,
	`lockedUserName` VARCHAR(101) NULL COLLATE 'utf8mb4_general_ci',
	`lockedEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`dueDateTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`dueAmountTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`orderNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceDateTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`nameTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`phoneNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`supplierSiteTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`taxNumberTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`bankAccountTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`sortCodeTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`swiftTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`ibanTR` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`documentType` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`invoiceStatus` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`invoicePOStatus` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`supplierStatus` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
	`requestId` INT(11) NULL,
	`supplierCompanyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci',
	`duplicateCount` BIGINT(21) NOT NULL,
	`isDuplicate` INT(1) NOT NULL,
	`approvalRange` DECIMAL(26,6) NULL,
	`is3PercentageRange` INT(1) NULL,
	`actionByRole` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view ezcloud.vwgetuser
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwgetuser` (
	`userId` INT(11) NOT NULL,
	`firstName` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`lastName` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`email` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`phoneNumber` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`approvalAmountFrom` DECIMAL(10,2) NULL,
	`approvalAmountTo` DECIMAL(17,2) NULL,
	`profileLogo` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`userRole` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`createdBy` INT(11) NULL,
	`createdDate` DATETIME NULL,
	`cfirstName` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`clastName` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`cemail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`teamId` INT(11) NULL,
	`companyLogo` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`companyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci',
	`isEmailVerified` TINYINT(1) NULL,
	`isPhoneVerified` TINYINT(1) NULL,
	`countryCode` VARCHAR(10) NULL COLLATE 'utf8mb4_general_ci',
	`search` VARCHAR(178) NULL COLLATE 'utf8mb4_general_ci',
	`isActive` TINYINT(1) NULL
) ENGINE=MyISAM;

-- Dumping structure for view ezcloud.vwsupplierrequest
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwsupplierrequest` (
	`requestId` INT(11) NOT NULL,
	`teamId` INT(11) NULL,
	`requestedBy` INT(11) NULL,
	`supplierEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`requestStatus` VARCHAR(25) NULL COLLATE 'utf8mb4_general_ci',
	`requestDate` DATETIME NULL,
	`companyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci',
	`companyLogo` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`requestedName` VARCHAR(101) NULL COLLATE 'utf8mb4_general_ci',
	`requestedEmail` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`supplierCompanyName` VARCHAR(100) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view ezcloud.vwgetaudit
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwgetaudit`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwgetaudit` AS SELECT logId,lg.invoiceId,lg.comment,lg.actionDate,lg.actionBy, CONCAT(us.firstName," ",IFNULL(us.lastName,""))actionName
from tblinvoicelog lg INNER JOIN tbluser us 
ON us.userId=lg.actionBy ORDER BY logId desc ;

-- Dumping structure for view ezcloud.vwgetcomment
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwgetcomment`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwgetcomment` AS SELECT cm.commentId,cm.comment,cm.postDate,cm.postedBy,cm.invoiceId,inv.invoiceNumber,
CONCAT(pb.firstName," ", ifnull(pb.lastName,''))postedByName,
pb.profileLogo postedByLogo, pb.email postedByEmail
  ,GROUP_CONCAT(CONCAT(`tg`.`firstName`,' ', IFNULL(`tg`.`lastName`,'')) SEPARATOR ',')tagByName,
 GROUP_CONCAT(tu.userId SEPARATOR ',')tagBy
FROM tblcomments cm 
INNER JOIN tblinvoicedetails inv ON inv.invoiceId=cm.invoiceId
INNER JOIN tbluser pb ON pb.userId=cm.postedBy
LEFT JOIN tbltageduser tu ON tu.commentId=cm.commentId
left JOIN tbluser tg ON tg.userId=tu.userId AND tu.commentId=cm.commentId
WHERE cm.isDeleted=0 GROUP BY cm.commentId ;

-- Dumping structure for view ezcloud.vwgetentityuser
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwgetentityuser`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwgetentityuser` AS select distinct `tm`.`invoiceSenderEmail` AS `email`,`sr`.`teamId` AS `teamId`,
`tm`.`companyName` AS `companyName`,`tm`.`entityType` AS `entityType`,`us`.`firstName` AS `firstName`,
`us`.`lastName` AS `lastName` from ((`tblteam` `tm` join `tblsupplierrequest` `sr` 
on(`sr`.`supplierEmail` = `tm`.`invoiceSenderEmail` and `sr`.`requestStatus` = 'Accepted')) 
left join `tbluser` `us` on(`us`.`email` = `sr`.`supplierEmail` and `us`.`isDeleted` = 0)) where `sr`.`isDeleted` = 0
union ALL 
 select `tm`.`invoiceSenderEmail` AS `email`,
 (select `tblteam`.`teamId` from `tblteam` where `tblteam`.`invoiceSenderEmail` = `rq`.`supplierEmail` limit 1) AS `teamId`,
 `tm`.`companyName` AS `companyName`,`tm`.`entityType` AS `entityType`,
 `us`.`firstName` AS `firstName`,`us`.`lastName` AS `lastName` 
 from ((`tblsupplierrequest` `rq` join `tblteam` `tm` on(`tm`.`teamId` = `rq`.`teamId`))
  left join `tbluser` `us` on(`us`.`userId` = `rq`.`requestedBy` and `us`.`isDeleted` = 0)) 
  where `rq`.`isDeleted` = 0 and `rq`.`requestStatus` = 'Accepted' ;

-- Dumping structure for view ezcloud.vwgetinvoicedetails
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwgetinvoicedetails`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwgetinvoicedetails` AS SELECT `inv`.`invoiceId` AS `invoiceId`,`inv`.`invoiceNumber` AS `invoiceNumber`,`inv`.`senderEmail` AS `senderEmail`, 
STR_TO_DATE(`dueDate`,'%Y-%m-%d') AS `dueDate`, STR_TO_DATE(`inv`.`dueDate`,'%Y-%m-%d') AS `dueDateYYYMMDD`,
`inv`.`receiverEmail` AS `receiverEmail`, CAST(CASE WHEN (`inv`.`dueAmount` = '' OR `inv`.`dueAmount` = NULL) THEN 0 ELSE `inv`.`dueAmount` END AS DECIMAL(10,2)) AS `dueAmount`,`inv`.`textractJson` AS `textractJson`,`inv`.`textTractStatus` AS `textTractStatus`,`inv`.`filePath` AS `filePath`,`inv`.`imageFilePath` AS `imageFilePath`,`inv`.`createdDate` AS `invCreatedDate`,`inv`.`orderNumber` AS `orderNumber`,`inv`.`success` AS `success`,`inv`.`textractFailed` AS `textractFailed`,`inv`.`manualExtractFailed` AS `manualExtractFailed`,`inv`.`extractEngineFailed` AS `extractEngineFailed`,`inv`.`status` AS `status`,`inv`.`invoiceType` AS `invoiceType`,`inv`.`actionBy` AS `actionBy`,`inv`.`actionDate` AS `actionDate`,`inv`.`name` AS `name`,`inv`.`invoiceDate` AS `invoiceDate`,`inv`.`supplierSite` AS `supplierSite`,`inv`.`taxNumber` AS `taxNumber`,`inv`.`bankAccount` AS `bankAccount`,`inv`.`sortCode` AS `sortCode`,`inv`.`swift` AS `swift`,`inv`.`iban` AS `iban`,`inv`.`supplierAddress2` AS `supplierAddress2`,`inv`.`city` AS `city`,`inv`.`state` AS `state`,`inv`.`postalCode` AS `postalCode`,`inv`.`country` AS `country`,`inv`.`supplierId` AS `supplierId`,`inv`.`supplierAddress` AS `supplierAddress`,`inv`.`invoiceCurrency` AS `invoiceCurrency`,`inv`.`invoiceAmount` AS `invoiceAmount`,`inv`.`paidAmount` AS `paidAmount`,`inv`.`taxTotal` AS `taxTotal`,`inv`.`totalAmount` AS `totalAmount`,`inv`.`invoiceDescription` AS `invoiceDescription`,`inv`.`phoneNumber` AS `phoneNumber`, DATE_FORMAT(`inv`.`createdDate`,'%b') AS `mntName`, YEAR(`inv`.`createdDate`) AS `invoiceYear`,(
SELECT CONCAT('[', GROUP_CONCAT(json_object('invoiceLineId',`tblinvoiceline`.`invoiceLineId`,'operatingUnit',`tblinvoiceline`.`operatingUnit`,'invoiceNumber',`inv`.`invoiceNumber`,'invoiceId',`tblinvoiceline`.`invoiceId`,'invoiceLineNumber',`tblinvoiceline`.`invoiceLineNumber`,'invoiceLineType',`tblinvoiceline`.`invoiceLineType`,'invoiceLineAmount',`tblinvoiceline`.`invoiceLineAmount`) SEPARATOR ','),']')
FROM `tblinvoiceline`
WHERE `tblinvoiceline`.`invoiceId` = `inv`.`invoiceId`) AS `invoiceLine`,`tm`.`invoiceSenderEmail` AS `invoiceSenderEmail`,`tm`.`teamId` AS `teamId`,`tm`.`autoApproval` AS `autoApproval`,`tm`.`createdDate` AS `teamCreatedDate`,`tm`.`teamType` AS `teamType`,
`tm`.`companyLogo` AS `companyLogo`,`tm`.`companyName` AS `companyName`,`tm`.`createdBy` AS `teamCreatedBy`,
`ld`.`lockId` AS `lockId`,`ld`.`lockedDate` AS `lockedDate`,`ld`.`lockedBy` AS `lockedBy`, 
CONCAT(`us`.`firstName`,' ',`us`.`lastName`) AS `lockedUserName`,`us`.`email` AS `lockedEmail`,
`inv`.`invoiceNumberTR` AS `invoiceNumberTR`,`inv`.`dueDateTR` AS `dueDateTR`,`inv`.`dueAmountTR` AS `dueAmountTR`,
`inv`.`orderNumberTR` AS `orderNumberTR`,`inv`.`invoiceDateTR` AS `invoiceDateTR`,`inv`.`nameTR` AS `nameTR`,
`inv`.`phoneNumberTR` AS `phoneNumberTR`,`inv`.`supplierSiteTR` AS `supplierSiteTR`,
`inv`.`supplierSiteTR` AS `taxNumberTR`,`inv`.`bankAccountTR` AS `bankAccountTR`,`inv`.`sortCodeTR` AS `sortCodeTR`,
`inv`.`swiftTR` AS `swiftTR`,`inv`.`ibanTR` AS `ibanTR`,`inv`.`supplierAddressTR` AS `supplierAddressTR`,
`inv`.`invoiceCurrencyTR` AS `invoiceCurrencyTR`,`inv`.`invoiceAmountTR` AS `invoiceAmountTR`,
`inv`.`documentType` AS `documentType`,`inv`.`documentTypeTR` AS `documentTypeTR`,`inv`.`paidAmountTR` AS `paidAmountTR`,
`inv`.`taxTotalTR` AS `taxTotalTR`,`inv`.`invoiceDescriptionTR` AS `invoiceDescriptionTR`,
`inv`.`totalAmountTR` AS `totalAmountTR`,`inv`.`invoiceStatus` AS `invoiceStatus`,`inv`.`invoicePOStatus` AS `invoicePOStatus`,
`inv`.`supplierStatus` AS `supplierStatus`,`inv`.`validationResponse` AS `validationResponse`,
`inv`.`validationRequestDate` AS `validationRequestDate`,`rq`.`requestId` AS `requestId`,
`ts`.`companyName` AS `supplierCompanyName`,ac.userRole actionByRole
FROM (((((`tblinvoicedetails` `inv`
LEFT JOIN `tblteam` `tm` ON(`tm`.`invoiceSenderEmail` = `inv`.`receiverEmail`))
LEFT JOIN `tblinvoicelockdetails` `ld` ON(`ld`.`invoiceId` = `inv`.`invoiceId`))
LEFT JOIN `tbluser` `us` ON(`us`.`userId` = `ld`.`lockedBy`))
LEFT JOIN `tblsupplierrequest` `rq` ON(`rq`.`teamId` = `tm`.`teamId` AND `rq`.`isDeleted` = 0 AND `rq`.`supplierEmail` = `inv`.`senderEmail` AND `rq`.`requestStatus` = 'Accepted'))
LEFT JOIN `tblteam` `ts` ON(`ts`.`invoiceSenderEmail` = `inv`.`senderEmail`))
LEFT JOIN tbluser ac ON ac.userId=inv.actionBy
WHERE `inv`.`isDeleted` = 0 ;

-- Dumping structure for view ezcloud.vwgetinvoicereport
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwgetinvoicereport`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwgetinvoicereport` AS SELECT inv.invoiceId,inv.invoiceNumber ,inv.senderEmail,dueDate,dueDateYYYMMDD,inv.receiverEmail , dueAmount,textractJson,textTractStatus,filePath,imageFilePath,
invCreatedDate,orderNumber,success,textractFailed,manualExtractFailed,extractEngineFailed,status,invoiceType,
actionBy,actionDate,inv.name ,invoiceDate,supplierSite,taxNumber,bankAccount,sortCode,swift,iban,supplierAddress2,
city, state,postalCode,country,supplierId,supplierAddress,invoiceCurrency,invoiceAmount,paidAmount,taxTotal,
totalAmount,invoiceDescription,inv.phoneNumber AS phoneNumber,  mntName,invoiceYear,invoiceLine,
invoiceSenderEmail, teamId,autoApproval,teamCreatedDate,teamType,companyLogo,companyName,teamCreatedBy,
lockId,lockedDate,lockedBy, lockedUserName,lockedEmail,invoiceNumberTR,dueDateTR,dueAmountTR,orderNumberTR,
invoiceDateTR,nameTR,phoneNumberTR,supplierSiteTR,taxNumberTR,bankAccountTR,sortCodeTR,swiftTR,ibanTR,
documentType,invoiceStatus,invoicePOStatus,supplierStatus,requestId,supplierCompanyName,
 COUNT(invoiceId)duplicateCount, (CASE WHEN (COUNT(invoiceId) > 1) THEN TRUE ELSE FALSE END)isDuplicate,
(inv.invoiceAmount/us.approvalAmountTo * 100) approvalRange,
(CASE WHEN inv.status="Approved" AND (inv.invoiceAmount/us.approvalAmountTo * 100) <= 3  THEN TRUE ELSE FALSE END)is3PercentageRange,
actionByRole
FROM vwgetinvoicedetails inv LEFT JOIN tbluser us
ON us.userId=inv.actionBy
GROUP BY invoiceNumber,senderEmail,dueDate,receiverEmail,dueAmount,orderNumber,
invoiceDate,NAME,invoiceAmount,dueAmount,invoiceLine
ORDER BY invoiceId ;

-- Dumping structure for view ezcloud.vwgetuser
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwgetuser`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwgetuser` AS SELECT `us`.`userId` AS `userId`,`us`.`firstName` AS `firstName`,`us`.`lastName` AS `lastName`,`us`.`email` AS `email`,`us`.`phoneNumber` AS `phoneNumber`,`us`.`approvalAmountFrom` AS `approvalAmountFrom`,`us`.`approvalAmountTo` AS `approvalAmountTo`,`us`.`profileLogo` AS `profileLogo`,`us`.`userRole` AS `userRole`,`us`.`createdBy` AS `createdBy`,`us`.`createdDate` AS `createdDate`,`cr`.`firstName` AS `cfirstName`,`cr`.`lastName` AS `clastName`,`cr`.`email` AS `cemail`,`mem`.`teamId` AS `teamId`,`tm`.`companyLogo` AS `companyLogo`,`tm`.`companyName` AS `companyName`,`us`.`isEmailVerified` AS `isEmailVerified`,`us`.`isPhoneVerified` AS `isPhoneVerified`,`us`.`countryCode` AS `countryCode`, CONCAT(`us`.`firstName`,'_',`us`.`lastName`,'_',`us`.`email`,'_',`us`.`userRole`) AS `search`
,us.isActive FROM (((`tbluser` `us`
LEFT JOIN `tbluser` `cr` ON(`cr`.`userId` = `us`.`createdBy`))
LEFT JOIN `tblteammembers` `mem` ON(`mem`.`userId` = `us`.`userId`))
LEFT JOIN `tblteam` `tm` ON(`tm`.`teamId` = `mem`.`teamId`))
WHERE `us`.`isDeleted` = 0 ;

-- Dumping structure for view ezcloud.vwsupplierrequest
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwsupplierrequest`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwsupplierrequest` AS select `sr`.`requestId` AS `requestId`,`sr`.`teamId` AS `teamId`,
`sr`.`requestedBy` AS `requestedBy`,`sr`.`supplierEmail` AS `supplierEmail`,`sr`.`requestStatus` AS `requestStatus`,
`sr`.`requestDate` AS `requestDate`,`tm`.`companyName` AS `companyName`,`tm`.`companyLogo` AS `companyLogo`,
concat(`us`.`firstName`,' ',IFNULL(`us`.`lastName`,"")) AS `requestedName`,`us`.`email` AS `requestedEmail`,
`st`.`companyName` AS `supplierCompanyName` from (((`tblsupplierrequest` `sr` join `tblteam` `tm` on(`tm`.`teamId` = `sr`.`teamId`))
 join `tbluser` `us` on(`us`.`userId` = `sr`.`requestedBy`)) 
 left join `tblteam` `st` on(`st`.`invoiceSenderEmail` = `sr`.`supplierEmail`)) where `sr`.`isDeleted` = 0 ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
