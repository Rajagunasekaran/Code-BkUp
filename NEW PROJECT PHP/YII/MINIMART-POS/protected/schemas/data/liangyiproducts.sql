insert  into `people`(`id`,`type`,`code`,`name`,`auxname`,`firstname`,`lastname`,`mobile`,`mail`,`website`,`mobile_addnls`,`fax`,`did`,`cost_center`,`mhcost`,`mhrate`,`geo_update_frq`,`work_hour_start`,`work_hour_end`,`status`,`loginenabled`,`enablecontact`,`enablepplauxname`,`created_at`,`updated_at`) 
values 
(2,'supplier','SX-00001','xavier',NULL,NULL,NULL,'','',NULL,NULL,NULL,NULL,NULL,'0.00','0.00',15,0,0,'ACTIVE',0,0,1,'2014-04-29 17:10:14','2014-04-29 17:10:14')
,(3,'supplier','SL-00001','lon',NULL,NULL,NULL,'','',NULL,NULL,NULL,NULL,NULL,'0.00','0.00',15,0,0,'ACTIVE',0,0,1,'2014-04-29 17:10:26','2014-04-29 17:10:26');

delete from `products`;
insert  into `products`(`category_id`,`code`,`name`,`unit_cp`,`unit_sp`,`unit_sp_per`,`stock`,`rol`,`enableprdauxname`,`created_at`,`updated_at`)
SELECT CATEGORY, ITEM_NO, ITEM_NAME, ITEM_PRICE, ITEM_PRICE, 0, 1000, 250, 1, null, null
FROM item_details;

/*delete from `productpeople`;
insert  into `productpeople`(`id`,`product_id`,`person_id`,`type`) 
values 
(1,1,3,'supplier')
,(2,2,3,'supplier')
,(3,3,3,'supplier')
,(4,4,3,'supplier')
,(5,5,3,'supplier')
,(6,6,3,'supplier')
,(7,7,3,'supplier')
,(8,8,3,'supplier')
,(9,9,3,'supplier')
,(10,10,3,'supplier')
,(11,11,3,'supplier')
,(12,12,3,'supplier')
,(13,13,2,'supplier')
,(14,14,2,'supplier')
,(15,15,2,'supplier')
,(16,16,2,'supplier')
,(17,17,2,'supplier')
,(18,18,2,'supplier')
,(19,19,2,'supplier')
,(20,20,2,'supplier')
,(21,21,2,'supplier')
,(22,22,2,'supplier')
,(23,23,2,'supplier')
,(24,24,2,'supplier')
,(25,25,3,'supplier')
,(26,26,3,'supplier')
,(27,27,3,'supplier')
,(28,28,3,'supplier')
,(29,29,3,'supplier')
,(30,30,3,'supplier')
,(31,31,3,'supplier')
,(32,32,3,'supplier')
,(33,33,3,'supplier')
,(34,34,3,'supplier')
,(35,35,3,'supplier')
,(36,36,3,'supplier')
,(37,37,2,'supplier')
,(38,38,2,'supplier')
,(39,39,2,'supplier')
,(40,40,2,'supplier')
,(41,41,2,'supplier')
,(42,42,2,'supplier')
,(43,43,2,'supplier')
,(44,44,2,'supplier')
,(45,45,2,'supplier')
,(46,46,2,'supplier')
,(47,47,2,'supplier');
*/