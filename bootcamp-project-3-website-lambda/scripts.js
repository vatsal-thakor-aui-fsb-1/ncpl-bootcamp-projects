// Add your API endpoint here
var API_ENDPOINT = "https://ic66qwg22c.execute-api.us-east-2.amazonaws.com/stage";

// AJAX POST request to save Inspection Report data
document.getElementById("saveinspection").onclick = function(){
    var inputData = {
        "inspectionid": $('#inspectionid').val(),
        "clientname": $('#clientname').val(),
        "class": $('#class').val(),
        "status": $('#status').val(),
        "notes": $('#notes').val()
    };
    $.ajax({
        url: API_ENDPOINT,
        type: 'POST',
        data:  JSON.stringify(inputData),
        contentType: 'application/json; charset=utf-8',
        success: function (response) {
            document.getElementById("inspectionSaved").innerHTML = "Inspection Report Saved!";
        },
        error: function () {
            alert("Error saving Inspection Report.");
        }
    });
}

// AJAX GET request to retrieve all Inspection Reports
document.getElementById("getInspectionReports").onclick = function(){  
    $.ajax({
        url: API_ENDPOINT,
        type: 'GET',
        contentType: 'application/json; charset=utf-8',
        success: function (response) {
            $('#inspectionReportTable tr').slice(1).remove();
            jQuery.each(response, function(i, data) {          
                $("#inspectionReportTable").append("<tr> \
                    <td>" + data['inspectionid'] + "</td> \
                    <td>" + data['clientname'] + "</td> \
                    <td>" + data['class'] + "</td> \
                    <td>" + data['status'] + "</td> \
                    <td>" + data['notes'] + "</td> \
                    </tr>");
            });
        },
        error: function () {
            alert("Error retrieving Inspection Reports.");
        }
    });
}
