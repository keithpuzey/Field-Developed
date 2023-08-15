// ProcessBLZReport.java
/**
This class (ProcessBLZReport) will take care of creating the public facing token that is needed for
non-BlazeMeter users to be able to review the BlazeMeter test execution report.

The method process_blzgrid_session needs to have a data_dict as input parameter. This particular data dictionary
will contain the following: api_key, api_secret, blzgrid_sessionId, and blz_base. These are the key entries needed
to determine the public-token, as well as to build the public URL that will need to be included in the test results
repository in JIRA.

*/


import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpResponse.BodyHandlers;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

public class ProcessBLZReport {

    private static final Logger LOGGER = LoggerFactory.getLogger(ProcessBLZReport.class);

    private static String blz_url;
    private static String blz_auth;

    private static String blz_base_url;
    private static String blzAuth_strEnc;

    private JSONParser blzRep_jsonParser = new JSONParser();
    private JSONObject blzRep_jsonObj = new JSONObject();
    private JSONObject resObj = new JSONObject();

    private void process_url_get_request() throws Exception {
        // Getting ready to execute the get request based off the blz_url that was built
        String header_basic = "Basic " + blzAuth_strEnc;

        HttpClient blz_client = HttpClient.newHttpClient();
        HttpResponse blz_response;

        String blz_result = null;

        HttpRequest blz_get_request = HttpRequest.newBuilder()
                .GET()
                .uri(new URI(blz_url))
                .header("Authorization", header_basic)
                .header("Accept", "application/json")
                .header("Content-Type", "application/json")
                .build();

        HttpResponse<String> get_response = blz_client.send(blz_get_request, BodyHandlers.ofString());

        blzRep_jsonObj = (JSONObject) blzRep_jsonParser.parse(String.valueOf(get_response.body()));

    }

    private void process_url_post_response() throws Exception
    {
        // Getting ready to execute the get request based off the blz_url that was built
        String header_basic = "Basic " + blzAuth_strEnc;

        HttpClient blz_client = HttpClient.newHttpClient();
        HttpResponse blz_response;

        String blz_result = null;

        HttpRequest blz_post_request = HttpRequest.newBuilder()
        .POST(HttpRequest.BodyPublishers.noBody())
        .uri(new URI(blz_url))
        .header("Authorization", header_basic)
        .header("Accept", "application/json")
        .header("Content-Type", "application/json")
        .build();

        HttpResponse<String> post_response = blz_client.send(blz_post_request, BodyHandlers.ofString());

        blzRep_jsonObj = (JSONObject) blzRep_jsonParser.parse(String.valueOf(post_response.body()));

    }
    public String process_blzgrid_session(Map<String, String> dict_data) throws Exception
    {
        try {
            // Setup the blz_base_url as defined in the input dict
            blz_base_url = dict_data.get("blz_url");
            //System.out.println("blz_base_url string: " + blz_base_url);

            // Now we need to setup the http basic authentication header
            blz_auth = dict_data.get("api") + ":" + dict_data.get("secret");
            //System.out.println("auth string: " + blz_auth);

            byte[] blzAuth_encBytes = Base64.getEncoder().encode(blz_auth.getBytes(StandardCharsets.UTF_8));
            blzAuth_strEnc = new String (blzAuth_encBytes);
            //System.out.println("blzAuth_strEnc: " + blzAuth_strEnc);

            //String blzgrid_sessionId = dict_data.get("grid_sessionId");
            //System.out.println("The sessionId passed is: " + blzgrid_sessionId);

            // build the URL that will be passed
            //blz_url = String.format("%s/grid/wd/hub/session/%s", blz_base_url, blzgrid_sessionId);
            //System.out.println("the grid session_id based URL: " + blz_url);

            // execute the get request
            //process_url_get_request();

            // storing the bzm_sessionId that will be used for the next step
            //String bzm_sessionId = (String) blzRep_jsonObj.get("sessionId");

            // now extracting the projectId and masterId
            //blz_url = String.format("%s/sessions/%s", blz_base_url, bzm_sessionId);
            //System.out.println("the bzm master session_id based URL: " + blz_url);

            //process_url_get_request();
            //resObj = (JSONObject) blzRep_jsonObj.get("result");

            // extracting the projectId
            //String bzm_projectId = String.valueOf(resObj.get("projectId"));

            // now extracting the masterId
            //String bzm_masterId = String.valueOf(resObj.get("masterId"));

            blz_url = String.format("%s/projects/%s", blz_base_url, dict_data.get("projectId"));
            //System.out.println("the get project URL: " + blz_url);

            // extracting the result set that will contain the workspaceId
            process_url_get_request();
            resObj = (JSONObject) blzRep_jsonObj.get("result");

            // extracting the workspaceId
            String bzm_workspaceId = String.valueOf(resObj.get("workspaceId"));

            blz_url = String.format("%s/workspaces/%s", blz_base_url, bzm_workspaceId);
            //System.out.println("the get workspace URL: " + blz_url);

            // now getting the accountId based off the workspaceId
            process_url_get_request();
            resObj = (JSONObject) blzRep_jsonObj.get("result");

            // extracting the accountId
            String bzm_accountId = String.valueOf(resObj.get("accountId"));
            //System.out.println("the accountId extracted: " + bzm_accountId);

            //blz_url = String.format("%s/masters/%s/public-token", blz_base_url, bzm_masterId);
            blz_url = String.format("%s/masters/%s/public-token", blz_base_url, dict_data.get("grid_reportId"));

            //System.out.println("the create public token URL: " + blz_url);

            process_url_post_response();
            resObj = (JSONObject) blzRep_jsonObj.get("result");

            // extracting the master report publicToken for this testcase
            String bzm_publicToken = String.valueOf(resObj.get("publicToken"));

            // now we are going to be building the BZM testcase public URL that can be shared with
            // others
            //String blzgrid_public_url = String.format(
            //        "https://a.blazemeter.com/app/?public-token=%s#/accounts/%s/workspaces/%s/projects/%s/masters/%s",
            //        bzm_publicToken, bzm_accountId, bzm_workspaceId, bzm_projectId, bzm_masterId);

            String blzgrid_public_url = String.format(
                    "https://a.blazemeter.com/app/?public-token=%s#/accounts/%s/workspaces/%s/projects/%s/masters/%s",
                    bzm_publicToken, bzm_accountId, bzm_workspaceId, dict_data.get("projectId"),
                    dict_data.get("grid_reportId"));

            return blzgrid_public_url;

        } catch (Exception e) {
            throw new Exception(e);
        }

    }

}
