<!--//*******************************************FILE DESCRIPTION*********************************************//
//*********************************DAILY REPORTS ADMIN REPORT ENTRY *************************************//
//DONE BY:RAJA
//VER 0.07-SD:10/01/2015 ED:10/01/2015, TRACKER NO:74,DESC:CHANGED PRELOADER POSITION AND IMPLEMENTED AUTOFOCUS
//DONE BY:RAJA
//VER 0.06-SD:05/01/2015 ED:07/01/2015, TRACKER NO:175,179,DESC:CHANGED LOGIN ID AS EMPLOYEE NAME, SETTING PRELOADER POSITON, MSGBOX POSITION
//DONE BY:SASIKALA
//VER 0.05-SD:06/01/2015 ED:06/01/2015, TRACKER NO:74,DESC:ADDED GEOLOCATION FOR MULTIPLE ENTRY
//DONE BY:SASIKALA
//VER 0.04-SD:28/12/2014 ED:29/12/2014, TRACKER NO:74,DESC:ADDED GEOLOCATION AND CHECKOUT TIME VALIDATION
//DONE BY:LALITHA
//VER 0.03-SD:01/12/2014 ED:01/12/2014,TRACKER NO:74,Changed Preloder funct,Removed Confirmation fr err msgs
//DONE BY:SASIKALA
//VER 0.02 SD:17/10/2014 ED 18/10/2014,TRACKER NO:74,DESC:DID PERMISSION AS MANDATORY AND BUTTON VALIDATION
//VER 0.01-INITIAL VERSION, SD:08/08/2014 ED:01/10/2014,TRACKER NO:74
//*********************************************************************************************************//-->
<?php
include "HEADER.php";
?>
<script>
var checkoutlocation;
function displayLocation(latitude,longitude){
    var request = new XMLHttpRequest();
    var method = 'GET';
    var url = 'http://maps.googleapis.com/maps/api/geocode/json?latlng='+latitude+','+longitude+'&sensor=true';
    var async = true;

    request.open(method, url, async);
    request.onreadystatechange = function(){
        if(request.readyState == 4 && request.status == 200){
            var data = JSON.parse(request.responseText);
            var address = data.results[0];
            checkoutlocation=address.formatted_address;
        }
    };
    request.send();
};
var successCallback = function(position){
    var x = position.coords.latitude;
    var y = position.coords.longitude;
    displayLocation(x,y);
};

var errorCallback = function(error){
    var errorMessage = 'Unknown error';
    switch(error.code) {
        case 1:
            errorMessage = 'Permission denied';
            break;
        case 2:
            errorMessage = 'Position unavailable';
            break;
        case 3:
            errorMessage = 'Timeout';
            break;
    }
    document.write(errorMessage);
};

var options = {
    enableHighAccuracy: true,
    timeout: 10000,
    maximumAge: 0
};

navigator.geolocation.getCurrentPosition(successCallback,errorCallback,options);

//READY FUNCTION START
$(document).ready(function(){
    $("#test").jqScribble();
    $('.preloader', window.parent.document).show();
    $('#ARE_tble_attendence').hide();
    $('#ARE_tbl_attendence').hide();
    $('#ARE_btn_save').hide();
    $("#ARE_btn_odsubmit").hide();
    var permission_array=[];
    var project_array=[];
    var min_date;
    var err_msg=[];
    var login_id=[];
    var xmlhttp=new XMLHttpRequest();
    xmlhttp.onreadystatechange=function() {
        if (xmlhttp.readyState==4 && xmlhttp.status==200) {
            $('.preloader', window.parent.document).hide();
            var value_array=JSON.parse(xmlhttp.responseText);
            permission_array=value_array[0];
//            project_array=value_array[1];
            min_date=value_array[2];
            err_msg=value_array[3];
            login_id=value_array[4];
            var maxdate=new Date();
            var month=maxdate.getMonth()+1;
            var year=maxdate.getFullYear();
            var date=maxdate.getDate();
            var max_date = new Date(year,month,date);
            var datepicker_maxdate=new Date(Date.parse(max_date));
            $('#ARE_tb_date').datepicker("option","maxDate",datepicker_maxdate);
            $('#ARE_tb_date').datepicker("option","minDate",min_date);
            var login_list='<option>SELECT</option>';
            for (var i=0;i<login_id.length;i++) {
                login_list += '<option value="' + login_id[i][1] + '">' + login_id[i][0] + '</option>';
            }
            $('#ARE_lb_loginid').html(login_list);
            var login_list='<option>SELECT</option>';
            for (var i=0;i<login_id.length;i++) {
                login_list += '<option value="' + login_id[i][1] + '">' + login_id[i][0] + '</option>';
            }
            $('#ARE_lb_lgnid').html(login_list);
        }
    }
    var option="admin_report_entry";
    xmlhttp.open("GET","COMMON.php?option="+option);
    xmlhttp.send();
    $('textarea').autogrow({onInitialize: true});
    $("#ARE_tb_band,#ARE_tb_date").html('')
    $('#ARE_tb_band').hide();
    $('#ARE_btn_submit').hide();
    //DATE PICKER FUNCTION
    $('#ARE_tb_date').datepicker({
        dateFormat:"dd-mm-yy",
        changeYear: true,
        changeMonth: true
    });
    $('#ARE_tb_dte').datepicker({
        dateFormat:"dd-mm-yy",
        changeYear: true,
        changeMonth: true
    });
    var od_maxdate=new Date();
    var month=od_maxdate.getMonth()+1;
    var year=od_maxdate.getFullYear();
    var date=od_maxdate.getDate();
    var OD_max_date = new Date(year,month,date);
    $('#ARE_tb_dte').datepicker("option","maxDate",OD_max_date);
    //CHANGE EVENT FOR LOGIN LIST BX
    $(document).on('change','#ARE_lb_loginid',function(){
//        $("html, body").animate({ scrollTop: $(document).height() }, "1000");
        $('#ARE_lbl_errmsg').hide();
        $('#ARE_lbl_checkmsg').hide();
        var ARE_loginidlistbx= $("#ARE_lb_loginid").val();
        $('#ARE_tble_attendence').hide();
        if(ARE_loginidlistbx=='SELECT')
        {
            $('#ARE_tble_attendence').hide();
            $('#ARE_lbl_dte').hide();
            $('#ARE_tb_date').hide();
            $('#ARE_lbl_session').hide();
            $('#ARE_lbl_reason').hide();
            $('#ARE_ta_reason').hide();
            $('#ARE_lb_ampm').hide();
            $('#ARE_lbl_report').hide();
            $('#ARE_ta_report').hide();
            $('#ARE_rd_permission').hide();
            $('#ARE_lbl_permission').hide();
            $('#ARE_rd_nopermission').hide();
            $('#ARE_lbl_nopermission').hide();
            $('#ARE_lb_timing').hide();
            $('#ARE_lbl_band').hide();
            $('#ARE_tb_band').hide();
            $("#ARE_btn_submit,#ARE_mrg_projectlistbx").html('');
            ARE_clear()

        }
        else
        {
            var newPos= adjustPosition($('#option').position(),80,270);
            resetPreloader(newPos);
            $('.maskpanel',window.parent.document).css("height","276px").show();
            $('.preloader').show();
            var loginid=$('#ARE_lb_loginid').val();
            var xmlhttp=new XMLHttpRequest();
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4 && xmlhttp.status==200) {

                    var final_array=JSON.parse(xmlhttp.responseText);
                    mindate=final_array[0];
                    project_array=final_array[1];
                    $('.maskpanel',window.parent.document).removeAttr('style').hide();
                    $('.preloader').hide();
                    if(project_array.length==0){

                        var msg=err_msg[10].replace('[LOGIN ID]',$("#ARE_lb_loginid option:selected").text());
                        $('#ARE_lbl_norole_err').text(msg).show();
                        $('#ARE_tb_date').hide();
                        $('#ARE_lbl_dte').hide();

                    }
                    else{
                        $('#ARE_tb_date').datepicker("option","minDate",mindate);
                        $('#ARE_lbl_norole_err').hide();
                        $('#ARE_tb_date').show();
                        $('#ARE_lbl_dte').show();
                    }

//                    $('#ARE_tb_date').datepicker("option","minDate",mindate);
                }
            }
            var choice="login_id"
            xmlhttp.open("GET","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?login_id="+loginid+"&option="+choice,true);
            xmlhttp.send();
            ARE_clear()
            $('#ARE_lbl_dte').show();
            $('#ARE_tb_date').val('').show();
            $('#ARE_lbl_session').hide();
            $('#ARE_lbl_reason').hide();
            $('#ARE_ta_reason').hide();
            $("#ARE_btn_submit,#ARE_mrg_projectlistbx").html('');
            $('#ARE_lb_ampm').hide();
            $('#ARE_lbl_report').hide();
            $('#ARE_ta_report').hide();
            $('#ARE_rd_permission').hide();
            $('#ARE_lbl_permission').hide();
            $('#ARE_rd_nopermission').hide();
            $('#ARE_lbl_nopermission').hide();
            $('#ARE_lb_timing').hide();
            $('#ARE_lbl_band').hide();
            $('#ARE_tb_band').hide();
        }
    });
    //JQUERY LIB VALIDATION START
    $("#ARE_tb_band").doValidation({rule:'numbersonly',prop:{realpart:10,leadzero:true}});
    $("#ARE_tb_band").prop("title","NUMBERS ONLY")
    $(".amountonly").doValidation({rule:'numbersonly',prop:{realpart:5,imaginary:2}});
    //JQUERY LIB VALIDATION END
    // CHANGE EVENT FOR DATE
    $(document).on('change','#ARE_tb_date',function(){
//        $("html, body").animate({ scrollTop: $(document).height() }, "1000");
        var newPos= adjustPosition($('#option').position(),100,270);
        resetPreloader(newPos);
        $('.maskpanel',window.parent.document).css("height","276px").show();
        $('.preloader').show();
        $('#ARE_lbl_checkmsg').hide();
        var reportdate=$('#ARE_tb_date').val();
        var loginid=$('#ARE_lb_loginid').val();
        var xmlhttp=new XMLHttpRequest();
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                var msgalert=xmlhttp.responseText;
                $('.maskpanel',window.parent.document).removeAttr('style').hide();
                $('.preloader').hide();
                if(msgalert==1)
                {
                    var msg=err_msg[3].toString().replace("[DATE]",reportdate)
                    ARE_clear()
                    $("#ARE_tb_date").val("");
//                    $("#ARE_lbl_dte").hide();
                    $('#ARE_tble_attendence').hide();
                    $('#ARE_lbl_errmsg').text(msg).show();
//                    $('#ARE_lb_loginid').val('SELECT').show();
                }
                else
                {
                    ARE_clear()
                    $('#ARE_tble_attendence').val('SELECT').show();
                    $('#ARE_lbl_errmsg').hide();
                    $('#ARE_lb_attendance').prop('selectedIndex',0);
                }
            }
        }
        var choice="DATE"
        xmlhttp.open("GET","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?date_change="+reportdate+"&login_id="+loginid+"&option="+choice,true);
        xmlhttp.send();
    });
    // CHANGE EVENT FOR ATTENDANCE
    $('#ARE_lb_attendance').change(function(){
        $("html, body").animate({ scrollTop: $(document).height() }, "1000");
        $('#ARE_tble_frstsel_projectlistbx').html('');
        $('#ARE_btn_submit').attr('disabled','disabled');
        $('#ARE_tble_reasonlbltxtarea').html('');
        if($('#ARE_lb_attendance').val()=='SELECT')
        {
            $('#ARE_rd_permission').hide();
            $('#ARE_lbl_permission').hide();
            $('#ARE_rd_nopermission').hide();
            $('#ARE_lbl_nopermission').hide();
            $('#ARE_lb_timing').hide();
            $('#ARE_tbl_enterthereport').html('');
            $('#ARE_tble_projectlistbx').hide();
            $('#ARE_tble_bandwidth').html('');
            $('#ARE_lbl_session').hide();
            $('#ARE_lb_ampm').hide();
            $('#ARE_btn_submit').hide();
            $('#ARE_lbl_errmsg').hide();
            $('#ARE_lbl_checkmsg').hide();
        }
        else if($('#ARE_lb_attendance').val()=='1')
        {
            var newPos= adjustPosition($('#ARE_lbl_sinentry').position(),70,270);
            resetPreloader(newPos);
            $('.maskpanel',window.parent.document).css("height","276px").show();
            $('.preloader').show();
            var reportdate=$('#ARE_tb_date').val();
            var loginid=$('#ARE_lb_loginid').val();
            var xmlhttp=new XMLHttpRequest();
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                    $('.maskpanel',window.parent.document).removeAttr('style').hide();
                    $('.preloader').hide();
                    var response=JSON.parse(xmlhttp.responseText);
                    if((response[0]==1) && (response[1]==0))
                    {
                        $('#ARE_lbl_checkmsg').text(err_msg[11]).show();
                        $('#ARE_lb_timing').hide();
                        $('#ARE_rd_permission').hide();
                        $('#ARE_lbl_permission').hide();
                        $('#ARE_rd_nopermission').hide();
                        $('#ARE_lbl_nopermission').hide();
                        $('#ARE_lbl_session').hide();
                        $('#ARE_lb_ampm').hide();
                        $('#ARE_lbl_txtselectproj').hide();
                        $('#ARE_tble_projectlistbx').hide();
                        $('#ARE_btn_submit').hide();
                        $('#ARE_lbl_errmsg').hide();
                    }
                    else{
                        $('#ARE_tbl_enterthereport,#ARE_ta_reason,#ARE_tble_bandwidth').html('');
                        $('#ARE_rd_permission').attr('checked',false);
                        $('#ARE_rd_nopermission').attr('checked',false);
                        $('#ARE_lb_timing').hide();
                        $('#ARE_rd_permission').show();
                        $('#ARE_lbl_permission').show();
                        $('#ARE_rd_nopermission').show();
                        $('#ARE_lbl_nopermission').show();
                        var permission_list='<option>SELECT</option>';
                        for (var i=0;i<permission_array.length;i++) {
                            permission_list += '<option value="' + permission_array[i] + '">' + permission_array[i] + '</option>';
                        }
                        $('#ARE_lb_timing').html(permission_list);
                        $('#ARE_lbl_session').hide();
                        $('#ARE_lb_ampm').hide();
                        $('#ARE_lbl_txtselectproj').show();
                        $('#ARE_tble_projectlistbx').show();
                        projectlist();
                        ARE_report();
                        ARE_tble_bandwidth();
                        $('#ARE_btn_submit').hide();
                        $('#ARE_rd_permission').removeAttr("disabled");
                        $('#ARE_rd_nopermission').removeAttr("disabled");
                        $('#ARE_lbl_errmsg').hide();
                        $('#ARE_lbl_checkmsg').hide();
                    }
                }
            }
            var option="PRESENT";
            xmlhttp.open("POST","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?option="+option+"&reportdate="+reportdate+"&loginid="+loginid);
            xmlhttp.send();
        }
        else if($('#ARE_lb_attendance').val()=='0')
        {
            $('#ARE_rd_permission').attr('checked',false);
            $('#ARE_rd_nopermission').attr('checked',false);
            $('#ARE_lb_timing').hide();
            $('#ARE_rd_permission').show();
            $('#ARE_lbl_permission').show();
            $('#ARE_rd_nopermission').show();
            $('#ARE_lbl_nopermission').show();
            var permission_list='<option>SELECT</option>';
            for (var i=0;i<4;i++) {
                permission_list += '<option value="' + permission_array[i] + '">' + permission_array[i] + '</option>';
            }
            $('#ARE_lb_timing').html(permission_list);
            $('#ARE_lbl_session').show();
            $('#ARE_lb_ampm').val('SELECT').show();
            $('#ARE_tble_projectlistbx').hide();
            $('#ARE_tble_reasonlbltxtarea').html('');
            $('#ARE_tbl_enterthereport').html('');
            $('#ARE_tble_bandwidth').html('');
            $('#ARE_btn_submit').hide();
            $('#ARE_rd_permission').attr('disabled','disabled');
            $('#ARE_rd_nopermission').attr('disabled','disabled');
            $('#ARE_lbl_errmsg').hide();
            $('#ARE_lbl_checkmsg').hide();
        }
        else if($('#ARE_lb_attendance').val()=='OD')
        {
            $('#ARE_rd_permission').attr('checked',false);
            $('#ARE_rd_nopermission').attr('checked',false);
            $('#ARE_lb_timing').hide();
            $('#ARE_rd_permission').show();
            $('#ARE_lbl_permission').show();
            $('#ARE_rd_nopermission').show();
            $('#ARE_lbl_nopermission').show();
            var permission_list='<option>SELECT</option>';
            for (var i=0;i<4;i++) {
                permission_list += '<option value="' + permission_array[i] + '">' + permission_array[i] + '</option>';
            }
            $('#ARE_lb_timing').html(permission_list);
            $('#ARE_lbl_session').show();
            $('#ARE_lb_ampm').val('SELECT').show();
            $('#ARE_tble_projectlistbx').hide();
            $('#ARE_tble_reasonlbltxtarea').html('');
            $('#ARE_tbl_enterthereport').html('');
            $('#ARE_tble_bandwidth').html('');
            $('#ARE_btn_submit').hide();
            $('#ARE_rd_permission').attr('disabled','disabled');
            $('#ARE_rd_nopermission').attr('disabled','disabled');
            $('#ARE_lbl_errmsg').hide();
            $('#ARE_lbl_checkmsg').hide();
        }
    });
    // CLICK EVENT PERMISSION RADIO BUTTON
    $(document).on('click','#ARE_rd_permission',function()
    {
//        $("html, body").animate({ scrollTop: $(document).height() }, "1000");
        if($('#ARE_rd_permission').attr("checked","checked"))
        {
            $('#ARE_lb_timing').val('SELECT').show();
        }
        else
        {
            $('#ARE_lb_timing').hide();
            $('#ARE_lb_timing').prop('selectedIndex',0);
        }
    });
    // CLICK EVENT NOPERMISSION RADIO BUTTON
    $(document).on('click','#ARE_rd_nopermission',function()
    {
        $('#ARE_lb_timing').hide();
        $('#ARE_lb_timing').prop('selectedIndex',0);

    });
// FUNCTION FOR CLEAR FORM ELEMENTS
    function ARE_clear(){
        $('#ARE_tble_attendence').hide();
        $('#ARE_tble_reasonlbltxtarea').html('');
        $('#ARE_tble_frstsel_projectlistbx').html('');
        $('#ARE_tbl_enterthereport').html('');
        $('#ARE_tble_bandwidth').html('');
        $('#ARE_btn_submit').html('');
        $('#ARE_lbl_session').hide();
        $('#ARE_rd_permission').hide();
        $('#ARE_lbl_permission').hide();
        $('#ARE_rd_nopermission').hide();
        $('#ARE_lbl_nopermission').hide();
        $('#ARE_lb_timing').hide();
        $('#ARE_lb_timing').prop('selectedIndex',0);
        $('#ARE_lb_ampm').hide();
        $('#ARE_btn_submit').hide();
        $('#ARE_tble_projectlistbx').hide();
        $('#ARE_lbl_norole_err').hide();
    }
    // CHANGE EVENT FOR SESSION LIST BOX
    $('#ARE_lb_ampm').change(function(){
        $("html, body").animate({ scrollTop: $(document).height() }, "1000");
        flag=1;
        $('#ARE_tble_reasonlbltxtarea,#ARE_tbl_enterthereport,#ARE_tble_bandwidth,#ARE_tble_frstsel_projectlistbx').html('');
        if($('#ARE_lb_ampm').val()=='SELECT')
        {
            $('#ARE_tble_reasonlbltxtarea').html('');
            $('#ARE_tble_frstsel_projectlistbx').html('');
            $('#ARE_tbl_enterthereport').html('');
            $('#ARE_tble_projectlistbx').hide();
            $('#ARE_tble_bandwidth').html('');
            $('#ARE_btn_submit').hide();
            $('#ARE_lbl_errmsg').hide();
            $('#ARE_lbl_checkmsg').hide();
        }
        else if($('#ARE_lb_ampm').val()=='FULLDAY')
        {
            $('#ARE_tble_projectlistbx').hide();
            ARE_reason();
            $('#ARE_lb_timing').hide();
            $('#ARE_rd_permission').hide();
            $('#ARE_lbl_permission').hide();
            $('#ARE_rd_nopermission').hide();
            $('#ARE_lbl_nopermission').hide();
            $('#ARE_rd_permission').attr('disabled','disabled');
            $('#ARE_rd_nopermission').attr('disabled','disabled');
            $('#ARE_btn_submit').show();
            $('#ARE_lbl_errmsg').hide();
            $('#ARE_lbl_checkmsg').hide();
        }
        else
        {
            var newPos= adjustPosition($('#ARE_tb_date').position(),20,270);
            resetPreloader(newPos);
            $('.maskpanel',window.parent.document).css("height","276px").show();
            $('.preloader').show();
            var reportdate=$('#ARE_tb_date').val();
            var loginid=$('#ARE_lb_loginid').val();
            var xmlhttp=new XMLHttpRequest();
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                    $('.maskpanel',window.parent.document).removeAttr('style').hide();
                    $('.preloader').hide();
                    var response=JSON.parse(xmlhttp.responseText);
                    if((response[0]==1) && (response[1]==0))
                    {
                        $('#ARE_lbl_checkmsg').text(err_msg[11]).show();
                        $('#ARE_btn_submit').hide();
                        $('#ARE_rd_permission').hide();
                        $('#ARE_lbl_permission').hide();
                        $('#ARE_rd_nopermission').hide();
                        $('#ARE_lbl_nopermission').hide();
                        $('#ARE_lb_timing').hide();
                        $('#ARE_tble_projectlistbx').hide();
                        $('#ARE_lbl_txtselectproj').hide();
                        $('#ARE_lbl_errmsg').hide();
                    }
                    else
                    {
                        ARE_reason();
                        $('#ARE_btn_submit').hide();
                        $('#ARE_rd_permission').attr('checked',false);
                        $('#ARE_rd_nopermission').attr('checked',false);
                        $('#ARE_rd_permission').removeAttr("disabled");
                        $('#ARE_rd_nopermission').removeAttr("disabled");
                        $('#ARE_rd_permission').show();
                        $('#ARE_lbl_permission').show();
                        $('#ARE_rd_nopermission').show();
                        $('#ARE_lbl_nopermission').show();
                        $('#ARE_lb_timing').hide();
                        $('#ARE_tble_projectlistbx').show();
                        $('#ARE_lbl_txtselectproj').show();
                        projectlist();
                        ARE_report();
                        ARE_tble_bandwidth();
                        $('#ARE_lbl_errmsg').hide();
                        $('#ARE_lbl_checkmsg').hide();
                    }
                }
            }
            var option="HALFDAYABSENT";
            xmlhttp.open("POST","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?option="+option+"&reportdate="+reportdate+"&logind="+loginid);
            xmlhttp.send();
        }
    });
    //CHANGE EVENT FOR REPORT TEXTAREA
    $(document).on('change','#ARE_ta_report',function(){

        $('#ARE_btn_submit').show();
        $('#ARE_btn_submit').attr('disabled','disabled');
        $('#ARE_lbl_errmsg').hide();
//        $('#ARE_tble_bandwidth').html('');
    });
    //CHANGE EVENT FOR BANDWIDTH TEXTBX
    $(document).on('change blur','#ARE_tb_band',function(){
        var bandwidth=$('#ARE_tb_band').val();
        if(bandwidth > 1000)
        {
            var msg=err_msg[9].toString().replace("[BW]",bandwidth);
            $('#ARE_lbl_errmsg').text(msg).show();
            $("ARE_btn_submit").attr("disabled", "disabled");
        }
        else
        {
            $('#ARE_lbl_errmsg').hide();
        }
    });
    // FUNCTION FOR PROJECT LIST
    function projectlist(){
        var project_list;
        for (var i=0;i<project_array.length;i++) {
            project_list += '<tr><td><input type="checkbox" id ="checkbox" name="checkbox[]" value="' + project_array[i][1] + '">' + project_array[i][0] + ' - '+ project_array[i][2]+'</td></tr>';
        }
        $('#ARE_tble_frstsel_projectlistbx').append(project_list).show();
    }
    //FUNCTION FOR REASON
    function ARE_reason(){
        $('<tr><td width="150"><label name="ARE_lbl_reason" id="ARE_lbl_reason" >REASON<em>*</em></label></td><td><textarea  name="ARE_ta_reason" id="ARE_ta_reason" ></textarea></td></tr>').appendTo($("#ARE_tble_reasonlbltxtarea"));
    }
    //FUNCTION FOR MULTIPLE ENTRY REASON
    function ARE_mulreason(){
        $('<tr><td width="150"><label name="ARE_lbl_reason" id="ARE_lbl_reason" >REASON<em>*</em></label></td><td><textarea  name="ARE_ta_reason" id="ARE_ta_reason" ></textarea></td></tr>').appendTo($("#ARE_tbl_reason"));
    }
    // FUNCTION FOR REPORT
    function ARE_report(){
        $('<tr><td width="150"><label name="ARE_lbl_report" id="ARE_lbl_report">ENTER THE REPORT<em>*</em></label></td><td><textarea  name="ARE_ta_report" id="ARE_ta_report" ></textarea></td></tr>').appendTo($("#ARE_tbl_enterthereport"));
    }
    // FUNCTION FOR BANDWIDTH
    function ARE_tble_bandwidth(){
        $('<tr><td width="150"><label name="ARE_lbl_band" id="ARE_lbl_band" >BANDWIDTH<em>*</em></label></td><td><input type="text" name="ARE_tb_band" id="ARE_tb_band" class="autosize amountonly" style="width:75px;"><td><label name="ARE_lbl_band" id="ARE_lbl_band">MB</label></td></td></tr></tr>').appendTo($("#ARE_tble_bandwidth"));
        $(".amountonly").doValidation({rule:'numbersonly',prop:{realpart:4,imaginary:2}});
    }
    //FORM VALIDATION
    $(document).on('change blur','#ARE_form_adminreportentry',function(){
        if($("input[name=entry]:checked").val()=="SINGLE DAY ENTRY"){
            var ARE_sessionlstbx= $("#ARE_lb_ampm").val();
            var ARE_reasontxtarea =$("#ARE_ta_reason").val();
            var ARE_reportenter =$("#ARE_ta_report").val();
            var ARE_bndtxt = $("#ARE_tb_band").val();
            var ARE_projectselectlistbx = $("input[id=checkbox]").is(":checked");
            var ARE_permissionlstbx = $("#ARE_lb_timing").val();
            var ARE_permission=$("input[name=permission]:checked").val()=="PERMISSION";
            var ARE_nopermission=$("input[name=permission]:checked").val()=="NOPERMISSION";
            var ARE_presenthalfdysvld=$("#ARE_lb_attendance").val();
            if(((ARE_presenthalfdysvld=='0') && (ARE_sessionlstbx=='AM' || ARE_sessionlstbx=="PM")) || ((ARE_presenthalfdysvld=='OD') && (ARE_sessionlstbx=='AM' || ARE_sessionlstbx=="PM") ))
            {
                if(((ARE_reasontxtarea.trim()!="")&&(ARE_reportenter!='')&&( ARE_projectselectlistbx==true) &&(ARE_bndtxt!='')&& (ARE_bndtxt<=1000) && ((ARE_permission==true) || (ARE_nopermission==true))))
                {
                    if(ARE_permission==true)
                    {
                        if(ARE_permissionlstbx!='SELECT')
                        {
                            $("#ARE_btn_submit").removeAttr("disabled");
                        }
                        else
                        {
                            $("#ARE_btn_submit").attr("disabled", "disabled");
                        }
                    }
                    else
                    {
                        $("#ARE_btn_submit").removeAttr("disabled");
                    }
                }
                else
                {
                    $("#ARE_btn_submit").attr("disabled", "disabled");
                }
            }
            else if((ARE_presenthalfdysvld=='0' && ARE_sessionlstbx=='FULLDAY') || (ARE_presenthalfdysvld=='OD' && ARE_sessionlstbx=='FULLDAY'))
            {
                if(ARE_reasontxtarea.trim()=="")
                {
                    $("#ARE_btn_submit").attr("disabled", "disabled");
                }
                else
                {
                    $("#ARE_btn_submit").removeAttr("disabled");
                }
            }
            else if(ARE_presenthalfdysvld=='1')
            {
                if(((ARE_reportenter.trim()!="")&&(ARE_bndtxt!='')&&(ARE_bndtxt<=1000)&&( ARE_projectselectlistbx==true) && ((ARE_permission==true) || (ARE_nopermission==true))))
                {
                    if(ARE_permission==true)
                    {
                        if(ARE_permissionlstbx!='SELECT')
                        {
                            $("#ARE_btn_submit").removeAttr("disabled");
                        }
                        else
                        {
                            $("#ARE_btn_submit").attr("disabled", "disabled");
                        }
                    }
                    else
                    {
                        $("#ARE_btn_submit").removeAttr("disabled");
                    }
                }
                else
                {
                    $("#ARE_btn_submit").attr("disabled", "disabled");
                }
            }
        }
        else if($("input[name=entry]:checked").val()=="MULTIPLE DAY ENTRY"){
            var ARE_reasontxtarea =$("#ARE_ta_reason").val();
            var ARE_presenthalfdysvld=$("#ARE_lb_attdnce").val();
            if((ARE_presenthalfdysvld=='0') || (ARE_presenthalfdysvld=='OD'))
            {
                if(ARE_reasontxtarea.trim()=="")
                {
                    $("#ARE_btn_save").attr("disabled", "disabled");
                }
                else
                {
                    $("#ARE_btn_save").removeAttr("disabled");
                }
            }
        }
    });
    // CLICK EVENT FOR SAVE BUTTON
    $(document).on('click','#ARE_btn_submit',function(){
        var newPos= adjustPosition($(this).position(),-130,270);
        resetPreloader(newPos);
        var request;
        var canvas = document.getElementById('test');
        var imgData = canvas.toDataURL("image/jpeg");
        $('.maskpanel',window.parent.document).css("height","276px").show();
        $('.preloader').show();
        var formElement = $('#ARE_form_adminreportentry').serialize();
        var choice="SINGLE DAY ENTRY";
        // Send Request
        request = $.ajax({
            url: "DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php",
            type: "POST",
            data: formElement+"&choice="+choice+"&string="+imgData+"&checkoutlocation="+checkoutlocation,
            success: function(response){
                var msg_alert=response;
                $('.maskpanel',window.parent.document).removeAttr('style').hide();
                $('.preloader').hide();
                if(msg_alert==1){
                    $(document).doValidation({rule:'messagebox',prop:{msgtitle:"ADMIN REPORT ENTRY",msgcontent:err_msg[0],position:{top:150,left:500}}});
                    $('#ARE_lbl_dte').hide();
                    $('#ARE_tb_date').hide();
                    ARE_clear();
                    $("#ARE_lb_loginid").val('SELECT').show();
                }
                else if(msg_alert==0)
                {
                    $(document).doValidation({rule:'messagebox',prop:{msgtitle:"ADMIN REPORT ENTRY",msgcontent:err_msg[4],position:{top:150,left:500}}});
                    $('#ARE_lbl_dte').hide();
                    $('#ARE_tb_date').hide();
                    ARE_clear();
                    $("#ARE_lb_loginid").val('SELECT').show();
                }
                else
                {
                    $(document).doValidation({rule:'messagebox',prop:{msgtitle:"ADMIN REPORT ENTRY",msgcontent:msg_alert,position:{top:150,left:500}}});
                    $('#ARE_lbl_dte').hide();
                    $('#ARE_tb_date').hide();
                    ARE_clear();
                    $("#ARE_lb_loginid").val('SELECT').show();
                }
            }
        });
    });
    // CHANGE EVENT FOR OPTION BUTTON
    $(document).on('change','#option',function(){
        $('#ARE_form_dailyuserentry').hide();
        $('#ARE_lbl_checkmsg').hide();
        if($('#option').val()=='ADMIN REPORT ENTRY')
        {
            $("#ARE_lbl_sinentry").show();
            $('#ARE_rd_sinentry').attr('checked',false);
            $('#ARE_rd_mulentry').attr('checked',false);
            $("#ARE_rd_sinentry").show();
            $("#ARE_lbl_mulentry").show();
            $("#ARE_rd_mulentry").show();
            $('#ARE_tble_ondutyentry').hide();
            $('#ARE_lbl_oderrmsg').hide();
        }
        else if(($('#option').val()=='ONDUTY REPORT ENTRY'))
        {
            $('#ARE_tble_ondutyentry').show();
            $('#ARE_lbl_session').hide();
            $('#ARE_tble_singledayentry').hide();
            $('#ARE_tble_mutipledayentry').hide();
            $('#ARE_tble_attendence').hide();
            ARE_clear()
            ARE_mulclear()
            $('#ARE_lbl_errmsg').text('').show();
            $("#ARE_ta_des").val('');
            $("#ARE_tb_dte").val('');
            $("#ARE_btn_odsubmit").attr("disabled", "disabled");
            $("#ARE_lbl_sinentry").hide();
            $("#ARE_rd_sinentry").hide();
            $("#ARE_lbl_mulentry").hide();
            $("#ARE_rd_mulentry").hide();
            $('#ARE_msg').hide();
            $("#ARE_lbl_multipleday").hide();
            $("#ARE_rd_sinemp").hide();
            $("#ARE_lbl_sinemp").hide();
            $("#ARE_rd_allemp").hide();
            $("#ARE_lbl_allemp").hide();
        }
        else
        {
            $('#ARE_tble_singledayentry').hide();
            $('#ARE_tble_mutipledayentry').hide();
            $('#ARE_tble_ondutyentry').hide();
            $('#ARE_tble_attendence').hide();
            ARE_clear()
            $('#ARE_rd_sinentry').attr('checked',false);
            $('#ARE_rd_mulentry').attr('checked',false);
            $("#ARE_lbl_sinentry").hide();
            $("#ARE_rd_sinentry").hide();
            $("#ARE_lbl_mulentry").hide();
            $("#ARE_rd_mulentry").hide();
        }
    });
    // CLICK EVENT FOR SINGLEDAYENTRY RADIO BUTTON
    $('#ARE_rd_sinentry').click(function(){
        $('#ARE_tble_singledayentry').show();
        $('#ARE_lbl_session').hide();
        $('#ARE_tble_ondutyentry').hide();
        $('#ARE_tble_mutipledayentry').hide();
        $('#ARE_lbl_loginid').show();
        $('#ARE_lb_loginid').val('SELECT').show();
        $('#ARE_lbl_reason').hide();
        $('#ARE_ta_reason').hide();
        ARE_clear()
        $('#ARE_tbl_attendence').hide();
        $('#ARE_btn_save').hide();
        $('#ARE_lbl_dte').hide();
        $('#ARE_tb_date').hide();
        $('#ARE_lbl_attdnce').hide();
        $('#ARE_lb_attdnce').hide();
        $("#ARE_lbl_multipleday").hide();
        $("#ARE_rd_sinemp").hide();
        $("#ARE_lbl_sinemp").hide();
        $("#ARE_rd_allemp").hide();
        $("#ARE_lbl_allemp").hide();
        $('#ARE_msg').hide();
    });
    // CLICK EVENT FOR MULTIPLEDAYENTRY RADIO BUTTON
    $("#ARE_rd_mulentry").click(function(){
        $("#ARE_lbl_multipleday").show();
        $("#ARE_rd_sinemp").show();
        $("#ARE_lbl_sinemp").show();
        $("#ARE_rd_allemp").show();
        $("#ARE_lbl_allemp").show();
        $('#ARE_lbl_loginid').hide();
        $('#ARE_lb_loginid').hide();
        $('#ARE_lbl_dte').hide();
        $('#ARE_tb_date').hide();
        $('#ARE_lbl_errmsg').hide();
        $('#ARE_rd_sinemp').attr('checked',false);
        $('#ARE_rd_allemp').attr('checked',false);
        ARE_clear()
        $('#ARE_lbl_checkmsg').hide();
    });
    //CLICK EVENT FOR SINGLE EMPLOYEE RADIO BUTTON
    $("#ARE_rd_sinemp").click(function(){
        $('#ARE_tble_mutipledayentry').show();
        $('#ARE_tble_singledayentry').hide();
        $('#ARE_lbl_lgnid').show();
        $('#ARE_lb_lgnid').val('SELECT').show();
        $("#ARE_lbl_sdte").hide();
        $("#ARE_tb_sdate").hide().val('');
        $("#ARE_lbl_edte").hide();
        $("#ARE_tb_edate").hide().val('');
        $('#ARE_tb_sdate').datepicker("option","minDate",mindate);
        $('#ARE_tb_sdate').datepicker("option","maxDate",max_date);
        $('#ARE_msg').hide();
        ARE_clear()
        ARE_mulclear()
    });
    // CLICK EVENT FOR ALL EMPLOYEE RADIO BUTTON
    $("#ARE_rd_allemp").click(function(){
        var xmlhttp=new XMLHttpRequest();
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                var allmindate=xmlhttp.responseText;
                $('#ARE_tb_sdate').datepicker("option","minDate",allmindate);
                var maxdate=new Date();
                var month=maxdate.getMonth()+1;
                var year=maxdate.getFullYear();
                var date=maxdate.getDate();
                var allmaxdate = new Date(year,month,date);
                $('#ARE_tb_sdate').datepicker("option","maxDate",allmaxdate);
            }
        }
        var choice="ALLEMPDATE"
        xmlhttp.open("GET","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?&option="+choice,true);
        xmlhttp.send();
        $('#ARE_tble_mutipledayentry').show();
        $('#ARE_tble_singledayentry').hide();
        $('#ARE_lbl_lgnid').hide();
        $('#ARE_lb_lgnid').hide();
        $('#ARE_lb_lgnid').prop('selectedIndex',0);
        $("#ARE_lbl_sdte").show();
        $("#ARE_tb_sdate").show().val('');
        $("#ARE_lbl_edte").show();
        $("#ARE_tb_edate").show().val('');
//        $('#ARE_tb_sdate').datepicker("option","minDate",null);
//        $('#ARE_tb_sdate').datepicker("option","maxDate",null);
        $('#ARE_table_attendence').hide();
        $('#ARE_lbl_attdnce').hide();
        $('#ARE_lb_attdnce').hide();
        $('#ARE_lbl_reason').hide();
        $('#ARE_ta_reason').hide();
        $('#ARE_btn_save').hide();
        $('#ARE_msg').hide();
        ARE_clear()
    });
    // CHANGE EVENT FOR MULTIPLEDAY ENTRY LOGIN LIST BOX
    $(document).on('change','#ARE_lb_lgnid',function(){
        $("#ARE_lbl_sdte").show();
        $("#ARE_tb_sdate").show().val('');
        $("#ARE_lbl_edte").show();
        $("#ARE_tb_edate").show().val('');
    });
    // DATEPICKER FUNCTION FOR FROMDATE AND TODATE
    $('.change').datepicker({
        dateFormat:"dd-mm-yy",
        changeYear: true,
        changeMonth: true
    });
    var mindate;
    var max_date;
    // CHANGE EVENT FOR MULTIPLE DAY LOGINID LISTBOX
    $(document).on('change','#ARE_lb_lgnid',function(){
//        $("html, body").animate({ scrollTop: $(document).height() }, "1000");
        $('#ARE_lbl_errmsg').hide();
        var ARE_loginidlist= $("#ARE_lb_lgnid").val();
        $('#ARE_tble_attendence').hide();
        if(ARE_loginidlist=='SELECT')
        {
            $('#ARE_table_attendence').hide();
            $("#ARE_lbl_sdte").hide();
            $("#ARE_tb_sdate").hide()
            $("#ARE_lbl_edte").hide();
            $("#ARE_tb_edate").hide();
            $('#ARE_lbl_reason').hide();
            $('#ARE_ta_reason').hide();
            ARE_clear()
        }
        else
        {
            var newPos= adjustPosition($('#option').position(),100,270);
            resetPreloader(newPos);
            $('.maskpanel',window.parent.document).css("height","276px").show();
            $('.preloader').show();
            var loginid=$('#ARE_lb_lgnid').val();
            var xmlhttp=new XMLHttpRequest();
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4 && xmlhttp.status==200) {

                    var mindate=xmlhttp.responseText;
                    $('.maskpanel',window.parent.document).removeAttr('style').hide();
                    $('.preloader').hide();
                    $('#ARE_tb_sdate').datepicker("option","minDate",mindate);
                    var max_date=new Date();
                    var month=max_date.getMonth()+1;
                    var year=max_date.getFullYear();
                    var date=max_date.getDate();
                    var max_date = new Date(year,month,date);
                    $('#ARE_tb_sdate').datepicker("option","maxDate",max_date);
                }
            }
            var choice="LOGINID"
            xmlhttp.open("GET","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?login_id="+loginid+"&option="+choice,true);
            xmlhttp.send();

            ARE_clear()
            $('#ARE_lbl_sdte').show();
            $('#ARE_tb_sdate').val('').show();
            $("#ARE_lbl_edte").show();
            $("#ARE_tb_edate").show();
            $('#ARE_lbl_reason').hide();
            $('#ARE_ta_reason').hide();
            $('#ARE_tble_attendence').hide();
            $('#ARE_lbl_attdnce').hide();
            $('#ARE_lb_attdnce').hide();
            $('#ARE_btn_save').hide();
        }
    });
    // CHANGE EVENT FOR FROMDATE
    $(document).on('change','#ARE_tb_sdate',function(){
//        $("html, body").animate({ scrollTop: $(document).height() }, "fast");
        var ARE_fromdate = $('#ARE_tb_sdate').datepicker('getDate');
        var date = new Date( Date.parse( ARE_fromdate ));
        date.setDate( date.getDate()  );
        var ARE_todate = date.toDateString();
        ARE_todate = new Date( Date.parse( ARE_todate ));
        $('#ARE_tb_edate').datepicker("option","minDate",ARE_todate);
        var max_date=new Date();
        var month=max_date.getMonth()+1;
        var year=max_date.getFullYear();
        var date=max_date.getDate();
        var max_date = new Date(year,month,date);
        $('#ARE_tb_edate').datepicker("option","maxDate",max_date);
    });
    // CHANGE FUNCTIOn FOR TODATE
    $(document).on('change','.valid',function(){
//        $("html, body").animate({ scrollTop: $(document).height() }, "fast");
        var loginid=$('#ARE_lb_lgnid').val();
        var fromdate=$('#ARE_tb_sdate').val();
        var todate=$('#ARE_tb_edate').val();
        if(fromdate!='' && todate!='')
        {
            var newPos= adjustPosition($('#ARE_lbl_mulentry').position(),100,270);
            resetPreloader(newPos);
            $('.maskpanel',window.parent.document).css("height","276px").show();
            $('.preloader').show();
            var xmlhttp=new XMLHttpRequest();
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                    $('.maskpanel',window.parent.document).removeAttr('style').hide();
                    $('.preloader').hide();
                    var date_array=JSON.parse(xmlhttp.responseText);
                    var error_date='';
                    for(var i=0;i<date_array.length;i++){
                        if(i==0){
                            error_date=date_array[i]
                        }
                        else{
                            error_date+=','+date_array[i]
                        }
                    }
                    if(error_date=='')
                    {
                        $('#ARE_tbl_attendence').show();
                        $('#ARE_lbl_attdnce').show();
                        $('#ARE_lb_attdnce').val('SELECT').show();
                        $('#ARE_msg').text(msg).hide();
                    }
                    else
                    {
                        var msg=err_msg[3].toString().replace("[DATE]",error_date);
                        $('#ARE_msg').text(msg).show();
//                    $('#ARE_tb_sdate').val('').show();
//                    $('#ARE_tb_edate').val('').show();
                        $('#ARE_tbl_attendence').hide();
                        $('#ARE_lbl_attdnce').hide();
                        $('#ARE_lb_attdnce').val('SELECT').hide();
                    }
                }
            }
            var option="BETWEEN DATE";
            xmlhttp.open("GET","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?option="+option+"&fromdate="+fromdate+"&todate="+todate+"&loginid="+loginid,true);
            xmlhttp.send();
        }
    });
    //CHANGE EVENT FOR MULTIPLEDAY ATTENDANCE
    $('#ARE_lb_attdnce').change(function(){
        $("html, body").animate({ scrollTop: $(document).height() }, "1000");
        $('#ARE_tbl_reason').html('');
        if($('#ARE_lb_attdnce').val()=='SELECT')
        {
            $('#ARE_lbl_reason').hide();
            $('#ARE_ta_reason').hide();
            $('#ARE_btn_save').hide();
        }
        else if(($('#ARE_lb_attdnce').val()=='0') || ($('#ARE_lb_attdnce').val()=='OD'))
        {
            ARE_mulreason()
            $('#ARE_lbl_reason').show();
            $('#ARE_ta_reason').show();
            $('#ARE_btn_save').show();
        }
    });
    //CLICK EVENT FOR MULTIPLEDAY SAVE BUTTON
    $('#ARE_btn_save').click(function(){
        var newPos= adjustPosition($('#ARE_lb_attdnce').position(),100,270);
        resetPreloader(newPos);
        $('.maskpanel',window.parent.document).css("height","276px").show();
        $('.preloader').show();
        var formElement = document.getElementById("ARE_form_adminreportentry");
        var xmlhttp=new XMLHttpRequest();
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                var msg_alert=xmlhttp.responseText;
                $('.maskpanel',window.parent.document).removeAttr('style').hide();
                $('.preloader').hide();
                if(msg_alert==1){
                    $(document).doValidation({rule:'messagebox',prop:{msgtitle:"ADMIN REPORT ENTRY",msgcontent:err_msg[0],position:{top:150,left:500}}});
                    ARE_mulclear()
                    $('#ARE_lbl_lgnid').hide();
                    $('#ARE_lb_lgnid').hide();
                    $('#ARE_rd_sinemp').attr('checked',false);
                    $('#ARE_rd_allemp').attr('checked',false);
                }
                else if(msg_alert==0)
                {
                    $(document).doValidation({rule:'messagebox',prop:{msgtitle:"ADMIN REPORT ENTRY",msgcontent:err_msg[4],position:{top:150,left:500}}});
                    ARE_mulclear()
                    $('#ARE_lbl_lgnid').hide();
                    $('#ARE_lb_lgnid').hide();
                    $('#ARE_rd_sinemp').attr('checked',false);
                    $('#ARE_rd_allemp').attr('checked',false);
                }
                else
                {
                    $(document).doValidation({rule:'messagebox',prop:{msgtitle:"ADMIN REPORT ENTRY",msgcontent:msg_alert,position:{top:150,left:500}}});
                    ARE_mulclear()
                    $('#ARE_lbl_lgnid').hide();
                    $('#ARE_lb_lgnid').hide();
                    $('#ARE_rd_sinemp').attr('checked',false);
                    $('#ARE_rd_allemp').attr('checked',false);
                }
            }
        }
        var choice="MULTIPLE DAY ENTRY";
        xmlhttp.open("POST","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?choice="+choice+"&reportlocation="+checkoutlocation,true);
        xmlhttp.send(new FormData(formElement));
    });
// FUNCTION FORM MULTIPLE ENTRY CLEAR FUNCTION
    function ARE_mulclear()
    {
        $('#ARE_lbl_sdte').hide();
        $('#ARE_tb_sdate').hide();
        $('#ARE_lbl_edte').hide();
        $('#ARE_tb_edate').hide();
        $('#ARE_lbl_reason').hide();
        $('#ARE_ta_reason').hide();
        $('#ARE_tbl_reason').html('');
        $('#ARE_btn_save').hide();
        $('#ARE_tbl_attendence').hide();
        $('#ARE_lbl_attdnce').hide();
        $('#ARE_lb_attdnce').hide();
        $('#ARE_lbl_norole_err').hide();
    }
    // ONDUTY ENTRY VALIDATION STARTS
    $('.enable').change(function(){
        if($("#ARE_ta_des").val()=='')
        {
            $("#ARE_btn_odsubmit").attr("disabled", "disabled");
        }
        else
        {
            $("#ARE_btn_odsubmit").removeAttr("disabled");
            $("#ARE_btn_odsubmit").show();
        }
    });
    //CHANGE EVENT ONDUTY ENTRY DATE FUNCTION
    $('#ARE_tb_dte').change(function(){
//        $("html, body").animate({ scrollTop: $(document).height() }, "fast");
        var newPos= adjustPosition($('#option').position(),70,270);
        resetPreloader(newPos);
        $('.maskpanel',window.parent.document).css("height","276px").show();
        $('.preloader').show();
        var reportdate=$('#ARE_tb_dte').val();
        var xmlhttp=new XMLHttpRequest();
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                var msgalert=xmlhttp.responseText;
                $('.maskpanel',window.parent.document).removeAttr('style').hide();
                $('.preloader').hide();
                if(msgalert==1)
                {
                    var msg=err_msg[3].toString().replace("[DATE]",reportdate);
                    $('#ARE_lbl_oderrmsg').text(msg).show();
                    $('#ARE_tb_dte').val('').show();
                }
                else
                {
                    $('#ARE_lbl_oderrmsg').text(msg).hide();
                    $('#ARE_lbl_des').show();
                    $("#ARE_ta_des").show();
                    $("#ARE_btn_odsubmit").show();
                }
            }

        }
        var choice="ODDATE"
        xmlhttp.open("GET","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?date_change="+reportdate+"&option="+choice,true);
        xmlhttp.send();
    });
// CLICK EVENT ONDUTY SAVE BUTTON
    $('#ARE_btn_odsubmit').click(function(){
        var newPos= adjustPosition($('#ARE_tb_dte').position(),100,270);
        resetPreloader(newPos);
        $('.maskpanel',window.parent.document).css("height","276px").show();
        $('.preloader').show();
        var formElement = document.getElementById("ARE_form_adminreportentry");
        var xmlhttp=new XMLHttpRequest();
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState==4 && xmlhttp.status==200) {
                var msg_alert=xmlhttp.responseText;
                $('.maskpanel',window.parent.document).removeAttr('style').hide();
                $('.preloader').hide();
                $(document).doValidation({rule:'messagebox',prop:{msgtitle:"ONDUTY ENTRY",msgcontent:msg_alert,position:{top:150,left:500}}});
                $('#ARE_tb_dte').val('');
                $('#ARE_ta_des').val('');
                $('#ARE_lbl_des').hide();
                $("#ARE_ta_des").hide();
                $("#ARE_btn_odsubmit").hide();
            }
        }
        var choice="ONDUTY";
        xmlhttp.open("POST","DB_DAILY_REPORTS_ADMIN_REPORT_ENTRY.php?option="+choice,true);
        xmlhttp.send(new FormData(formElement));
    });
});
function save()
{
    $("#test").data("jqScribble").save(function(imageData)
    {
        if(confirm("This will write a file using the example image_save.php. Is that cool with you?"))
        {
            $.post('image_save.php', {imagedata: imageData}, function(response)
            {
                $('body').append(response);
            });
        }
    });
}
//function addImage()
//{
//    var img = prompt("Enter the URL of the image.");
//    if(img !== '')$("#test").data("jqScribble").update({backgroundImage: img});
//}
function savepdf()
{
    var canvas = document.getElementById('test');
    var imgData = canvas.toDataURL("image/png", 1.0);
    var pdf = new jsPDF();
    pdf.addImage(imgData, 'JPEG', 0, 0);
    pdf.save('file.pdf');
}
//DOCUMENT READY FUNCTION END
</script>
<!--SCRIPT TAG END-->
</head>
<!--HEAD TAG END-->
<!--BODY TAG START-->
<body>
<div class="wrapper">
    <div  class="preloader MaskPanel"><div class="preloader statusarea" ><div style="padding-top:90px; text-align:center"><img src="image/Loading.gif"  /></div></div></div>
    <div class="title"><div style="padding-left:500px; text-align:left;" ><p><h3>ADMIN REPORT ENTRY</h3><p></div></div>
    <form   id="ARE_form_adminreportentry" class="content" >
        <table>
            <tr>
                <td width="150"><label name="ARE_lbl_optn" id="ARE_lbl_optn" >SELECT A OPTION</label><em>*</em></td>
                <td width="150">
                    <select id="option" name="option">
                        <option>SELECT</option>
                        <option>ADMIN REPORT ENTRY</option>
                        <option>ONDUTY REPORT ENTRY</option>
                    </select>
                </td>
            </tr>
        </table>
        <table>
            <tr>
                <td><input type="radio" id="ARE_rd_sinentry" name="entry" value="SINGLE DAY ENTRY"hidden/>
                    <label name="entry" id="ARE_lbl_sinentry" hidden>SINGLE DAY ENTRY</label></td>
            </tr>
            <tr>
                <td><input type="radio" id="ARE_rd_mulentry" name="entry" value="MULTIPLE DAY ENTRY"hidden/>
                    <label name="entry" id="ARE_lbl_mulentry" hidden>MULTIPLE DAY ENTRY</label></td>
            </tr>
            <tr>
                <td><label name="ARE_lbl_multipleday" id="ARE_lbl_multipleday" class="srctitle" hidden>MULTIPLE DAY ENTRY</label></td>
            </tr>
            <tr>
                <td><input type="radio" id="ARE_rd_sinemp" name="ARE_rd_emp" value="FOR SINGLE EMPLOYEE"hidden/>
                    <label name="ARE_lbl_emp" id="ARE_lbl_sinemp" hidden>FOR SINGLE EMPLOYEE</label></td>
            </tr>
            <tr>
                <td><input type="radio" id="ARE_rd_allemp" name="ARE_rd_emp" value="FOR ALL EMPLOYEE"hidden/>
                    <label name="ARE_lbl_emp" id="ARE_lbl_allemp" hidden>FOR ALL EMPLOYEE</label></td>
            </tr>
        </table>
        <table id="ARE_tble_singledayentry" hidden>
            <tr>
                <td width="150">
                    <label name="ARE_lbl_loginid" id="ARE_lbl_loginid" >EMPLOYEE NAME</label></td>
                <td>
                    <select name="ARE_lb_loginid" id="ARE_lb_loginid">
                    </select><br>
                </td><td><label id="ARE_lbl_norole_err" name="ARE_lbl_norole_err" class="errormsg" ></label></td></tr><br>
            <tr>
                <td width="150"><label name="ARE_lbl_dte" id="ARE_lbl_dte" hidden>DATE</label></td>
                <td><input type ="text" id="ARE_tb_date" class='proj datemandtry' hidden name="ARE_tb_date" style="width:75px;" /></td>
            </tr>
            <table id="ARE_tble_attendence" >
                <tr>
                    <td width="150"><label name="ARE_lbl_attendance" id="ARE_lbl_attendance" >ATTENDANCE</label></td>
                    <td width="150">
                        <select id="ARE_lb_attendance" name="ARE_lb_attendance">
                            <option>SELECT</option>
                            <option value="1">PRESENT</option>
                            <option value="0">ABSENT</option>
                            <option value="OD">ONDUTY</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td><input type="radio" name="permission" id="ARE_rd_permission" class='permissn'value="PERMISSION" hidden >
                        <label name="ARE_permission" id="ARE_lbl_permission">PERMISSION<em>*</em></label></td>
                    <td>
                        <select name="ARE_lb_timing" id="ARE_lb_timing" hidden >

                        </select>
                    </td>
                </tr>
                <tr>
                    <td><input type="radio" name="permission" id="ARE_rd_nopermission" class='permissn' value="NOPERMISSION" hidden >
                        <label name="ARE_nopermission" id="ARE_lbl_nopermission">NO PERMISSION<em>*</em></label></td>
                </tr>
                <tr>
                    <td><label name="ARE_lbl_session" id="ARE_lbl_session" hidden >SESSION</label></td>
                    <td><select name="ARE_lb_ampm" id="ARE_lb_ampm" >
                            <option>SELECT</option>
                            <option>FULLDAY</option>
                            <option>AM</option>
                            <option>PM</option>
                        </select></td>
                </tr>
            </table>
            <table id="ARE_tble_reasonlbltxtarea"></table>
            <table id="ARE_tble_projectlistbx" hidden>
                <tr><td width="150"><label name="ARE_lbl_txtselectproj" id="ARE_lbl_txtselectproj" >PROJECT</label><em>*</em></td>
                    <td> <table id="ARE_tble_frstsel_projectlistbx" ></table></td>
                </tr>
            </table>
            <table id="ARE_tbl_enterthereport"></table>
            <table  style="height: 200px" width="700" id="ARE_tbl_paintbox">
                <tr>
                    <td width="153"><label id="ARE_lbl_paint">PAINT</label></td>
                    <td>
                        <div id="content">
                            <!--<h1 id="plugin-name">wPaint.js</h1>-->

                            <div class="content-box">
                                <script src="http://parall.ax/parallax/js/jspdf.js"></script>
                                <!-- jQuery UI -->
                                <script type="text/javascript" src="./lib/jquery.ui.core.1.10.3.min.js"></script>
                                <script type="text/javascript" src="./lib/jquery.ui.widget.1.10.3.min.js"></script>
                                <script type="text/javascript" src="./lib/jquery.ui.mouse.1.10.3.min.js"></script>
                                <script type="text/javascript" src="./lib/jquery.ui.draggable.1.10.3.min.js"></script>

                                <!-- wColorPicker -->
                                <link rel="Stylesheet" type="text/css" href="./lib/wColorPicker.min.css" />
                                <script type="text/javascript" src="./lib/wColorPicker.min.js"></script>

                                <!-- wPaint -->
                                <link rel="Stylesheet" type="text/css" href="./wPaint.min.css" />
                                <script type="text/javascript" src="./wPaint.min.js"></script>
                                <script type="text/javascript" src="./plugins/main/wPaint.menu.main.min.js"></script>
                                <script type="text/javascript" src="./plugins/text/wPaint.menu.text.min.js"></script>
                                <script type="text/javascript" src="./plugins/shapes/wPaint.menu.main.shapes.min.js"></script>
                                <script type="text/javascript" src="./plugins/file/wPaint.menu.main.file.min.js"></script>

                                <div id="wPaint" style="position:relative; width:500px; height:200px; background-color:#7a7a7a; margin:70px auto 20px auto;"></div>
                                <!--<canvas id="wPaint" style="border: 1px solid red;" width="800" height="202"></canvas>-->
                                <center style="margin-bottom: 50px;">
                                    <input type="button" value="toggle menu" onclick="console.log($('#wPaint').wPaint('menuOrientation')); $('#wPaint').wPaint('menuOrientation', $('#wPaint').wPaint('menuOrientation') === 'vertical' ? 'horizontal' : 'vertical');"/>
                                </center>

                                <center id="wPaint-img"></center>

                                <script type="text/javascript">
                                    var images = [
                                        '/test/uploads/wPaint.png',
                                    ];
                                    function saveImg(image) {
                                        var _this = this;
                                        $.ajax({
                                            type: 'POST',
                                            url: '/test/upload.php',
                                            data: {image: image},
                                            success: function (resp) {
                                                // internal function for displaying status messages in the canvas
                                                _this._displayStatus('Image saved successfully');
                                                // doesn't have to be json, can be anything
                                                // returned from server after upload as long
                                                // as it contains the path to the image url
                                                // or a base64 encoded png, either will work
                                                resp = $.parseJSON(resp);
                                                // update images array / object or whatever
                                                // is being used to keep track of the images
                                                // can store path or base64 here (but path is better since it's much smaller)
                                                images.push(resp.img);
                                                // do something with the image
                                                $('#wPaint-img').attr('src', image);
                                            }
                                        });
                                    }
                                    function loadImgBg () {
                                        // internal function for displaying background images modal
                                        // where images is an array of images (base64 or url path)
                                        // NOTE: that if you can't see the bg image changing it's probably
                                        // becasue the foregroud image is not transparent.
                                        this._showFileModal('bg', images);
                                    }
                                    function loadImgFg () {
                                        // internal function for displaying foreground images modal
                                        // where images is an array of images (base64 or url path)
                                        this._showFileModal('fg', images);
                                    }
                                    function saveImageOnSite() {  //variable to hold request
                                        var imageData = $("#wPaint").wPaint("image");
                                        alert(imageData);
                                        $("#canvasImage").attr('src', imageData);
                                        $("#canvasImageData").val(imageData);
                                        var request; // define current folder
                                        var myloc = window.location.href;
                                        var locarray = myloc.split("/");
                                        delete locarray[(locarray.length-1)];
                                        var currentfolder = locarray.join("/");
                                        // generate random file name
                                        var randomnumbername='generated_images/' + Math.floor(Math.random()*1000000000000) + '.png';
                                        // Send Request
                                        request = $.ajax({ url: "saver.php", type: "post", data: { 'strng': imageData , 'namee': randomnumbername} });
                                        alert("Your image url: " + currentfolder + randomnumbername)};
                                    // init wPaint
                                    $('#wPaint').wPaint({
                                        menuOffsetLeft: 0,
                                        menuOffsetTop: -50,
                                        saveImg: saveImg,
                                        loadImgBg: loadImgBg,
                                        loadImgFg: loadImgFg
                                    });
                                </script>
                            </div>
                        </div>
                    </td>
                </tr>
            </table>
            <table id="ARE_tble_bandwidth"></table>
            <tr>
                <input type="button"  class="btn" name="ARE_btn_submit" id="ARE_btn_submit"  value="SAVE"/>
            </tr>

            <td><label id="ARE_lbl_errmsg" name="ARE_lbl_errmsg" class="errormsg"></label></td>
            <td><label id="ARE_lbl_checkmsg" name="ARE_lbl_checkmsg" class="errormsg"></label></td>
        </table>
        <table id="ARE_tble_mutipledayentry" hidden>
            <tr>
                <td width="150">
                    <label name="ARE_lbl_lgnid" id="ARE_lbl_lgnid" >EMPLOYEE NAME</label></td>
                <td>
                    <select name="ARE_lb_lgnid" id="ARE_lb_lgnid">
                    </select><br>
                </td></tr><br>
            <tr>
                <td width="150"><label name="ARE_lbl_sdte" id="ARE_lbl_sdte" hidden>FROM DATE</label></td>
                <td><input type ="text" id="ARE_tb_sdate" class='proj datemandtry change valid' hidden name="ARE_tb_sdate" style="width:75px;" /></td>
            </tr>
            <tr>
                <td width="150"><label name="ARE_lbl_edte" id="ARE_lbl_edte" hidden>TO DATE</label></td>
                <td><input type ="text" id="ARE_tb_edate" class='proj datemandtry change valid' hidden name="ARE_tb_edate" style="width:75px;" /></td>
            </tr>
            <table id="ARE_tbl_attendence">
                <tr>
                    <td width="150"><label name="ARE_lbl_attdnce" id="ARE_lbl_attdnce" >ATTENDANCE</label></td>
                    <td width="150">
                        <select id="ARE_lb_attdnce" name="ARE_lb_attdnce">
                            <option>SELECT</option>
                            <option value="0">ABSENT</option>
                            <option value="OD">ONDUTY</option>
                        </select>
                    </td>
                </tr>
            </table>
            <table id="ARE_tbl_reason"></table>
            <input type="button"  class="btn" name="ARE_btn_save" id="ARE_btn_save"  value="SAVE" >
            </tr>
            <td><label id="ARE_msg" name="ARE_msg" class="errormsg"></label></td>
        </table>
        <table id="ARE_tble_ondutyentry" hidden>
            <tr>
                <td width="150"> <label name="ARE_lbl_dte" id="ARE_lbl_dte">DATE</label></td>
                <td><input type="text" id="ARE_tb_dte" name="ARE_tb_dte" class='proj datemandtry enable' style="width:75px;"/></td>
            </tr>
            <tr>
                <td width="150"> <label name="ARE_lbl_des" id="ARE_lbl_des" hidden>DESCRIPTION</label></td>
                <td><textarea id="ARE_ta_des" name="ARE_ta_des" class='enable' hidden></textarea></td>
            </tr>
            <tr>
                <td><input type="button" id="ARE_btn_odsubmit" name="ARE_btn_odsubmit" value="SAVE" class="btn" disabled hidden /></td>
            </tr>
        </table>
        <label id="ARE_lbl_oderrmsg" name="ARE_lbl_oderrmsg" class="errormsg"></label>
    </form>
</div>
</body>
<!--BODY TAG END-->
</html>
<!--HTML TAG END-->