<?php
class Mdl_existing_unit extends CI_Model{
    public function Initial_data($EU_unitno,$EU_flag_unitno_err_roomstamp){
        $this->load->model('Eilib/Common_function');
        $EU_TB_roombox=[];
        $EU_TB_stampbox=[];
        $EU_arr_nonactive=[];
        $ErrorMessage='';
        $EU_unitnoarr='';
        if($EU_flag_unitno_err_roomstamp=='EU_flag_unitno_errormsg'){
            $ErrorMessage= $this->Common_function->getErrorMessageList('2,8,10,3,14,30,308,316,324,399,401,463,464,466,467');
            $EU_unitnoarr=$this->Common_function->GetActiveUnit();
            $EU_select_nonactive = "SELECT * FROM VW_NON_ACTIVE_UNIT ORDER BY UNIT_NO ASC";
            $EU_rs_nonactive = $this->db->query($EU_select_nonactive);
            foreach($EU_rs_nonactive->result_array() as $row)
            {
                $EU_arr_nonactive[]=($row["UNIT_NO"]);
            }
        }
        else if(($EU_flag_unitno_err_roomstamp=='EU_flag_roomstamp')||($EU_flag_unitno_err_roomstamp=='EU_flag_deposit_roomstamp')||($EU_flag_unitno_err_roomstamp=='EU_flag_roomtype')||($EU_flag_unitno_err_roomstamp=='EU_flag_stamptype')){
            $EU_select_query_room_type = "SELECT URTD_ROOM_TYPE FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE IS NOT NULL AND URTD_ID NOT IN(SELECT distinct URTD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=".$EU_unitno.") AND URTD_ID IS NOT NULL) ORDER BY URTD_ROOM_TYPE ASC";
            $EU_roomtype_rs = $this->db->query($EU_select_query_room_type);
            foreach($EU_roomtype_rs->result_array() as $row)
            {
                $EU_all_room_type = $row["URTD_ROOM_TYPE"];
                $EU_TB_roombox[]=($EU_all_room_type);
            }
            $EU_select_query_stamp_type="SELECT USDT_DATA FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA IS NOT NULL AND USDT_ID NOT IN(SELECT distinct USDT_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=".$EU_unitno.") AND USDT_ID IS NOT NULL) ORDER BY USDT_DATA ASC";
            $EU_stamptype_rs =$this->db->query($EU_select_query_stamp_type);
            foreach($EU_stamptype_rs->result_array() as $row)
            {
                $EU_all_stamp_type = $row["USDT_DATA"];
                $EU_TB_stampbox[]=($EU_all_stamp_type);
            }
        }
        $EU_result=(object)["EU_errarray"=>$ErrorMessage,"EU_roomtype"=>$EU_TB_roombox,"EU_stamp"=>$EU_TB_stampbox,"EU_unitno"=>$EU_unitnoarr,"EU_nonactive"=>$EU_arr_nonactive,"EU_unitno_flag"=>$EU_unitno,"EU_unitno_err_roomstamp_flag"=>$EU_flag_unitno_err_roomstamp];
        return [$EU_result];
    }
    public function EU_already_exists($EU_alreadyexist,$EU_source){
        $this->load->model('Eilib/Common_function');
        $EU_flag=[];
        if($EU_source=="EU_tb_accesscard"){
            $EU_flag=$this->Common_function->Check_ExistsCard($EU_alreadyexist);
        }
        else if($EU_source=="EU_tb_newroomtype"){
          $UC_chkroomtype='';
          $UC_chkroomtype=$this->db->escape_like_str($EU_alreadyexist);
          $EU_flag=$this->Common_function->Check_ExistsRmType($UC_chkroomtype);
        }
        else if($EU_source=="EU_tb_newstamptype"){
            $UC_chkstamptype='';
            $UC_chkstamptype=$this->db->escape_like_str($EU_alreadyexist);
            $EU_flag=$this->Common_function->Check_ExistsStampduty($UC_chkstamptype);
        }
        else if(($EU_source=="UNIT_tb_doorcode")||($EU_source=="UNIT_tb_weblogin")){
            $EU_flag[0]=1;
            $EU_flag=$this->Common_function->Check_ExistsDoorcodeLogin($EU_alreadyexist,$EU_source);
        }
        return $EU_flag;
    }
    public function Login_acct_others($EU_unitnumber,$EU_source){
        $EU_unitno_select="SELECT * FROM UNIT WHERE UNIT_NO=".$EU_unitnumber;
        $EU_unitno_rs=$this->db->query($EU_unitno_select);
        $EU_unitno=$EU_unitno_rs->row()->UNIT_ID;
        if($EU_source=='EU_radio_doorloginpswd')
        {
            $EU_doorcode=null; $EU_weblogin=null; $EU_webpass=null;
            $EU_login_select="SELECT * FROM UNIT_LOGIN_DETAILS WHERE UNIT_ID=".$EU_unitno;
            $EU_login_rs=$this->db->query($EU_login_select);
            $EU_array_login='';
            foreach($EU_login_rs->result_array() as $row)
            {
                $EU_doorcode = $row["ULDTL_DOORCODE"];
                $EU_weblogin = $row["ULDTL_WEBLOGIN"];
                $EU_webpass = $row["ULDTL_WEBPWD"];
            }
            $EU_array_login=(object)["EU_dcode"=>$EU_doorcode,"EU_weblogin"=>$EU_weblogin,"EU_webpass"=>$EU_webpass];
            return $EU_array_login;
        }
        else if($EU_source=='EU_radio_acctdetails')
        {
            $EU_array_acct=[];
            $EU_acctno=null; $EU_acctname=null; $EU_bankcode=null; $EU_branchcode=null; $EU_bankaddrs=null;
            $EU_radio_select="SELECT * FROM UNIT_ACCOUNT_DETAILS WHERE UNIT_ID=".$EU_unitno;
            $EU_radio_rs=$this->db->query($EU_radio_select);
            foreach($EU_radio_rs->result_array() as $row)
            {
                $EU_acctno = $row["UACD_ACC_NO"];
                $EU_acctname = $row["UACD_ACC_NAME"];
                $EU_bankcode = $row["UACD_BANK_CODE"];
                $EU_branchcode = $row["UACD_BRANCH_CODE"];
                $EU_bankaddrs = $row["UACD_BANK_ADDRESS"];
            }
            $EU_array_acct=(object)["EU_acctnum"=>$EU_acctno,"EU_acctname"=>$EU_acctname,"EU_bankcode"=>$EU_bankcode,"EU_branchcode"=>$EU_branchcode,"EU_bankaddress"=>$EU_bankaddrs];
            return $EU_array_acct;
        }
        else if($EU_source=='EU_radio_others')
        {
            $EU_others_select="SELECT * FROM UNIT_DETAILS WHERE UNIT_ID=".$EU_unitno;
            $EU_others_rs=$this->db->query($EU_others_select);
            $EU_deposit='';
            foreach($EU_others_rs->result_array() as $row)
            {
                $EU_deposit = $row["UD_DEPOSIT"];
                if($EU_deposit==null){
                    $EU_deposit='';
                }
            }
            $EU_deposit_roomstamp=$this->Initial_data($EU_unitnumber,'EU_flag_deposit_roomstamp');
            return [$EU_deposit_roomstamp[0],$EU_deposit];
        }
    }
}