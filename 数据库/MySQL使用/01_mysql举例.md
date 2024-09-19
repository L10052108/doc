

## mysql 举例

### 表相关

```sql

use `zctx-expert`;

-- ----------------------------
-- 手术室灯光控制——手术安排表
-- ----------------------------
DROP TABLE IF EXISTS `op_operating_room_plan`;
CREATE TABLE `op_operating_room_plan`  (
 `id`                 bigint(20) NOT NULL AUTO_INCREMENT                             COMMENT '手术安排的id',
 `operate_his_id`         varchar(128)  NOT NULL                                     COMMENT '手术的id(HIS)',
 `room_id`             bigint(20)    NOT NULL                                         COMMENT '手术室的id,op_operating_room.id',
 `operate_room_id`     varchar(128)  NOT NULL                                         COMMENT 'HIS系统手术室的id',
 `patient_name`     varchar(128)  NOT NULL                                         COMMENT '手术患者姓名',
 `inpatient_ward`     varchar(128)  NOT NULL                                         COMMENT '病区',
 `patient_bed_no`     varchar(128)  NOT NULL                                         COMMENT '病床号',
 `operate_name`     varchar(128)  NOT NULL                                         COMMENT '手术名称',
 `operate_start_time`     datetime      NOT NULL                                     COMMENT '手术开始时间精确到日yyyy-MM-dd',
 `patient_bracelet_num` varchar(128)  NOT NULL                                     COMMENT '手环的编号',
 `patient_bracelet_mac` varchar(128)  NOT NULL                                     COMMENT '手环的mac',
 `main_docter_name`     varchar(128)  NOT NULL                                     COMMENT '第一洗手医生',
 `main_nurse_name`         varchar(128)                                               COMMENT '第一巡回护士',
 `remark`                 varchar(128)  NOT NULL                                     COMMENT '备注',
 `deleted`                tinyint(1) not NULL DEFAULT 0                             COMMENT '0:正常,1:删除',
 `create_time` datetime DEFAULT CURRENT_TIMESTAMP                                 COMMENT '创建时间',
 `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP     COMMENT '更新时间',
 
  PRIMARY KEY (`id`) 
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COMMENT = '手术室灯光控制——手术安排表';

-- 默认组织招天下
 INSERT INTO `organize` 
 (`id`, `organize_name`, `is_default`, `parent_organize_id`, `parent_node`, `sync_project_time`, `sync_project_time_unit`, `creator`, `create_time`, `modifier`, `modify_time`) 
 VALUES 
 (1, '招天下', 1, 0, '0', 0, 1, '招天下', now(), '招天下', now());

-- ----------------------------
-- 唯一索引
-- ----------------------------
-- 名称唯一索引
CREATE UNIQUE INDEX uk_organize_organizeName_parentOrganizeId ON organize(organize_name, parent_organize_id);

-- 一个组织只能一个归属机构
CREATE UNIQUE INDEX uk_organize_affiliation_organizeId ON organize_affiliation(organize_id);

-- ----------------------------
-- 删除数
-- ----------------------------
-- 删除项目表 数据
TRUNCATE TABLE bid_evaluation_record;  -- 清空数据，重新建表结构
delete from bid_evaluation_record where id = 10;  -- 不清空数据
 
-- ----------------------------
-- 修改表字段
-- ----------------------------
 ALTER TABLE z_bidding_record CHANGE bidder_code bidder_sn varchar(54)  COMMENT '竞买号';
 
 -- ----------------------------
-- 新增字段
-- ----------------------------
ALTER TABLE `pre_expert_staff` 
ADD COLUMN `other_file_images` varchar(255) NULL COMMENT '其他材料附件id,多个用英文逗号隔开' AFTER `work_year`;

ALTER TABLE `expert_staff` 
ADD COLUMN `other_file_images` varchar(255) NULL COMMENT '其他材料附件id,多个用英文逗号隔开' AFTER `work_year`;

-- 多个字段
ALTER TABLE `expert_bank` 
add COLUMN  `bank_type` tinyint(1) NULL DEFAULT 0 COMMENT '专家库类型：0-普通专家库1-监狱专家库...' AFTER `default_state`;
add COLUMN `age_limit` tinyint(1) DEFAULT 0 COMMENT '是否年龄限制0:不限制1:限制' AFTER `bank_type`;
add COLUMN `max_limit_age`   int(11) DEFAULT NULL COMMENT '限制的年龄' AFTER `age_limit`;
 
```

