

## 东阳人民医院建表语句

## op_led

```sql

-- ----------------------------
-- 手术室灯光控制——手术安排表
-- ----------------------------
DROP TABLE IF EXISTS `op_operating_room_plan`;
CREATE TABLE `op_operating_room_plan`  (
 `id` 				bigint(20) NOT NULL AUTO_INCREMENT 							COMMENT '手术安排的id',
 `operate_his_id` 		varchar(128)  NOT NULL 									COMMENT '手术的id(HIS)',
 `room_id` 			bigint(20)    NOT NULL 										COMMENT '手术室的id,op_operating_room.id',
 `operate_room_id` 	varchar(128)  NOT NULL 										COMMENT 'HIS系统手术室的id',
 `patient_name` 	varchar(128)  NOT NULL 										COMMENT '手术患者姓名',
 `inpatient_ward` 	varchar(128)  NOT NULL 										COMMENT '病区',
 `patient_bed_no` 	varchar(128)  NOT NULL 										COMMENT '病床号',
 `operate_name` 	varchar(128)  NOT NULL 										COMMENT '手术名称',
 `operate_start_time` 	datetime      NOT NULL 									COMMENT '手术开始时间精确到日yyyy-MM-dd',
 `patient_bracelet_num` varchar(128)  NOT NULL 									COMMENT '手环的编号',
 `patient_bracelet_mac` varchar(128)  NOT NULL 									COMMENT '手环的mac',
 `main_docter_name` 	varchar(128)  NOT NULL 									COMMENT '第一洗手医生',
 `main_nurse_name` 		varchar(128)  		 									COMMENT '第一巡回护士',
 `remark` 				varchar(128)  NOT NULL 									COMMENT '备注',
 `deleted`				tinyint(1) not NULL DEFAULT 0 							COMMENT '0:正常,1:删除',
 `create_time` datetime DEFAULT CURRENT_TIMESTAMP 								COMMENT '创建时间',
 `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT '更新时间',
 
  PRIMARY KEY (`id`) 
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COMMENT = '手术室灯光控制——手术安排表';

-- ----------------------------
-- 手术室灯光控制——手术室记录表
-- ----------------------------
DROP TABLE IF EXISTS `op_operating_record`;
CREATE TABLE `op_operating_record`  (
 `id` 				bigint(20) NOT NULL AUTO_INCREMENT 							COMMENT '手术室状态表',
 `operate_his_id` 	varchar(128)   NOT NULL 									COMMENT '手术的id(HIS)',
 `plan_id` 			bigint(20)    NOT NULL 										COMMENT '手术安排表的id, op_operating_room_plan.id',
 `deleted`				tinyint(1) not NULL DEFAULT 0 							COMMENT '0:正常,1:删除',
 `operating_status`		tinyint(1) not NULL DEFAULT 0 							COMMENT '手术的状态0:病人进入手术室1:手术开始2:手术完成3:手术结束',
 `operating_start_time` datetime DEFAULT CURRENT_TIMESTAMP 						COMMENT '手术开始的时间',
 `operating_end_time` datetime 												 	COMMENT '手术结束的时间',
 
 `create_time` datetime DEFAULT CURRENT_TIMESTAMP 								COMMENT '创建时间',
 `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT '更新时间',
 
  PRIMARY KEY (`id`) 
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COMMENT = '手术室灯光控制——手术记录表';


-- ----------------------------
-- 手术室灯光控制——医院手术室表
-- ----------------------------
DROP TABLE IF EXISTS `op_operating_room`;
CREATE TABLE `op_operating_room`  (
  `id` 				bigint(20) NOT NULL AUTO_INCREMENT 							COMMENT 'id',
  `his_operate_room_id` varchar(128)  NOT NULL 									COMMENT 'HIS系统的手术室的id',
  `room_no` 		varchar(50)  NOT NULL 										COMMENT '手术室编号',
  `room_name` 		varchar(50)  NOT NULL 										COMMENT '手术室名称',
  `room_area` 		varchar(50)  NOT NULL 										COMMENT '手术房间所在的区1:A,2:B,3:C,4:D',
  `room_remark` 	varchar(128)  NOT NULL 										COMMENT '手术室备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP 								COMMENT '创建时间',
  `deleted`			tinyint(1) not NULL DEFAULT 0 								COMMENT '0:正常,1:删除',
  PRIMARY KEY (`id`) 
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COMMENT = '手术室控制——医院手术室表';



-- ALTER TABLE `op_operating_room` 
-- ADD COLUMN `his_operate_room_id` BIGINT NULL AFTER `id`;


-- 写入数据
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA01','手术室1', '二楼1号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA02','手术室2', '二楼2号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA03','手术室3', '二楼3号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA04','手术室4', '二楼4号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA05','手术室5', '二楼5号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA06','手术室6', '二楼6号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA07','手术室7', '二楼7号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA08','手术室8', '二楼8号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA09','手术室9', '二楼9号手术室' ,0);
insert into op_operating_room(room_no, room_name, room_remark, deleted) VALUES ('DRA10','手术室10', '二楼10号手术室' ,0);

-- ----------------------------
-- 手术室灯光控制——手环表
-- ----------------------------
DROP TABLE IF EXISTS `op_bracelet`;
CREATE TABLE `op_bracelet`  (
 `id`				 bigint(20) NOT NULL AUTO_INCREMENT 						COMMENT '手环的id',
 `bracelet_num` 		varchar(20)  DEFAULT NULL 								COMMENT '手环编号',
 `mac_address` 		varchar(20) not null  										COMMENT '手术手环的mac',
 `bracelet_type` 	 	 TINYINT	   											COMMENT '手环的类型1:放射器2:病人手环',
 `electric_quantity` double    DEFAULT NULL 									COMMENT '电量',
 `power`			 varchar(10)  DEFAULT NULL 									COMMENT '功率',
 `create_time` datetime DEFAULT CURRENT_TIMESTAMP 								COMMENT '创建时间',
 `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `mac_address` (`mac_address`) 
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COMMENT = '手环信息表' ;

-- 测试数据

insert into op_bracelet (`bracelet_num` ,`mac_address`) VALUES ('001', '000000003A64');
insert into op_bracelet (`bracelet_num` ,`mac_address`) VALUES ('002', '000000003A65');

-- ----------------------------
-- 手术室灯光控制——基站表
-- ----------------------------
DROP TABLE IF EXISTS `op_station`;
CREATE TABLE `op_station`  (
  `id` 				bigint(20) NOT NULL AUTO_INCREMENT  						COMMENT '基站的id',
  `station_num` 	varchar(10)  DEFAULT NULL 									COMMENT '基站编号',
  `mac_address` 	varchar(20)  DEFAULT NULL    								COMMENT '设备的mac地址',
  `status` 			int(4) not null DEFAULT 1  									COMMENT '状态0:关闭 1:正常  2:异常 ',
  `address` 		varchar(150) DEFAULT NULL 									COMMENT '基站的ip地址',
  `descriptions` 	varchar(150)  DEFAULT NULL 									COMMENT '描述',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP 								COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT '更新时间',
    PRIMARY KEY (`id`) ,
    UNIQUE INDEX `mac_address` (`mac_address`),
	UNIQUE INDEX `station_num` (`station_num`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COMMENT = '基站表' ;

-- 测试数据
insert into op_station (`station_num` ,`mac_address`) VALUES ('001', '000000003A64');
insert into op_station (`station_num` ,`mac_address`) VALUES ('002', '000000003A65');

-- ----------------------------
-- 手术室灯光控制——灯带控制器
-- ----------------------------
DROP TABLE IF EXISTS `op_led_control`;
CREATE TABLE `op_led_control`  (
  `id` 				bigint(20) NOT NULL AUTO_INCREMENT  						COMMENT '灯带控制器的id',
  `led_control_num` varchar(10)  DEFAULT NULL 									COMMENT '灯带控制器编号',
  `mac_address` 	varchar(20)  DEFAULT NULL    								COMMENT '灯带控制器的mac地址',
  `status` 			char(4) 													COMMENT '继电器状态(暂时不用)',
  `address` 		varchar(150) DEFAULT NULL 									COMMENT '灯带控制器ip地址',
  `descriptions` 	varchar(150)  DEFAULT NULL 									COMMENT '描述',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP 								COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT '更新时间',
  
    PRIMARY KEY (`id`) ,
    UNIQUE INDEX `mac_address` (`mac_address`),
	UNIQUE INDEX `led_control_num` (`led_control_num`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COMMENT = '灯带控制器' ;

-- 测试数据
insert into op_led_control (`led_control_num` ,`mac_address`) VALUES ('001', '000000003A64');
insert into op_led_control (`led_control_num` ,`mac_address`) VALUES ('002', '000000003A65');

```

