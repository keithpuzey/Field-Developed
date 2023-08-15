//import org.apache.hc.client5.http.classic.HttpClient;
//import org.apache.hc.client5.http.classic.methods.HttpPost;
//import org.apache.hc.client5.http.entity.UrlEncodedFormEntity;
/*
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.NameValuePair;
import org.apache.hc.core5.http.message.BasicNameValuePair;
import org.apache.hc.client5.http.classic.*;
import org.apache.hc.client5.http.entity.*;
import org.apache.hc.core5.http.*;
*/

import io.cucumber.java.en.Given;
import org.joda.time.DateTime;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;
import org.junit.runner.Description;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.Select;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.net.URI;
import java.net.URL;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;

import static org.junit.Assert.assertEquals;


public class BZMGridTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(BZMGridTest.class);
    private static final String BASE = "a.blazemeter.com";
    private static final String CURL = String.format("https://%s/api/v4/grid/wd/hub", BASE);
    private static final String CURL_PROXY = String.format("https://%s/api/v4/grid/wd/hub/proxy/start", BASE);

    private static String API_KEY = "";
    private static String API_SECRET = "";
    private static String HARBOR_ID = "";
    private static int PROJECT_ID = 0;
    private static String BLZ_RPT_FILEPATH = "";

    private static List<String> BLZ_BROWSER_LIST;

    private static StringBuilder htmlStringBuilder = new StringBuilder();

    private static RemoteWebDriver driver;
    private static RemoteWebDriver chrome_driver;
    private static RemoteWebDriver firefox_driver;
    private static RemoteWebDriver edge_driver;

    @Rule
    public final TestName bzmTestCaseReporter = new TestName() {
        @Override
        protected void starting(Description description) {
            Map<String, String> map = new HashMap<>();
            map.put("testCaseName", description.getMethodName());
            map.put("testSuiteName", description.getClassName());
            driver.executeAsyncScript("/* FLOW_MARKER test-case-start */", map);
        }

        @Override
        protected void succeeded(Description description) {
            if (driver != null) {
                Map<String, String> map = new HashMap<>();
                map.put("status", "success");
                map.put("message", "success success");
                driver.executeAsyncScript("/* FLOW_MARKER test-case-stop */", map);

            }
        }

        @Override
        protected void failed(Throwable e, Description description) {
            Map<String, String> map = new HashMap<>();
            if (e instanceof AssertionError) {
                map.put("status", "failed");
                map.put("message", "failed failed");
            } else {
                map.put("status", "broken");
                map.put("message", "broken broken");
            }

            driver.executeAsyncScript("/* FLOW_MARKER test-case-stop */", map);
        }
    };

    @BeforeClass
    public static void setUp() throws Exception {
        // processing the environment variable
        String controlFile = System.getenv("CONTROL_FILE");
        if (controlFile != null)
        {
            process_configFile(controlFile);
        } else
        {
            throw new RuntimeException("The environment variable CONTROL_FILE has not been defined!");
        }

        // the values that are common to all browsers
        String REPORT_NAME = "Report Basic Selenium Java test";
        String BROWSER_VERSION = "default"; // BZL is using version 98 as the latest version
        String SESSION_NAME = "";
        String TEST_NAME = "";

        /** Now we need to setup a dictionary that will be passed to the process_blzgrid_session method for the creation
         of the public view of the report for the given set of tests.
         */

        // These are the chrome entries
        ChromeOptions chromeOptions = new ChromeOptions();
        Map<String, String> browser_chrome_pub_rep_dict = new HashMap<>();

        browser_chrome_pub_rep_dict.put("api", API_KEY);
        browser_chrome_pub_rep_dict.put("secret", API_SECRET);
        browser_chrome_pub_rep_dict.put("blz_url", String.format("https://%s/api/v4", BASE));

        // These are the firefox entries
        FirefoxOptions firefoxOptions = new FirefoxOptions();
        Map<String, String> browser_firefox_pub_rep_dict = new HashMap<>();

        browser_firefox_pub_rep_dict.put("api", API_KEY);
        browser_firefox_pub_rep_dict.put("secret", API_SECRET);
        browser_firefox_pub_rep_dict.put("blz_url", String.format("https://%s/api/v4", BASE));

        // these are the MS Edge entries
        EdgeOptions msedgeOptions = new EdgeOptions();
        Map<String, String> browser_msedge_pub_rep_dict = new HashMap<>();

        browser_msedge_pub_rep_dict.put("api", API_KEY);
        browser_msedge_pub_rep_dict.put("secret", API_SECRET);
        browser_msedge_pub_rep_dict.put("blz_url", String.format("https://%s/api/v4", BASE));

        // creating a generic hashmap that will contain all the blazemeter options
        HashMap<String, String> bzmOptions = new HashMap<>();
        bzmOptions.put("blazemeter.reportName", REPORT_NAME);
        //bzmOptions.put("blazemeter.sessionName", SESSION_NAME);
        //bzmOptions.put("blazemeter.testName", TEST_NAME);
        bzmOptions.put("blazemeter.apiKey", API_KEY);
        bzmOptions.put("blazemeter.apiSecret", API_SECRET);
        bzmOptions.put("blazemeter.buildId", getBuildId());
        bzmOptions.put("blazemeter.locationId", HARBOR_ID);
        bzmOptions.put("blazemeter.proxy.locationId", HARBOR_ID);
        bzmOptions.put("blazemeter.projectId", Integer.toString(PROJECT_ID));
        bzmOptions.put("blazemeter.videoEnabled", "True");

        // setting up the report prior to publication
        blzReportTable("BT BlazeMeter TestCase Run");
        blzTable("Browsers used");

        // now we are going to go thru the browser list
        int browser_listno = BLZ_BROWSER_LIST.size();
        int browser_counter = 0;
        String browser_name = null;
        while (browser_counter < browser_listno) {
            //System.out.println("List value " + browser_counter + " contents are: " + BLZ_BROWSER_LIST.get(browser_counter));
            browser_name = BLZ_BROWSER_LIST.get(browser_counter);

            // now determining the browser that will be called...
            if (browser_name.equals("chrome") | browser_name.equals("all")) {
                //System.out.println("The browser being called is chrome for this example");

                // setting up the chrome options to be used
                SESSION_NAME = "Session Selenium Chrome JAVA";
                TEST_NAME = "Selenium Chrome JAVA Grid Test";

                chromeOptions.setBrowserVersion(BROWSER_VERSION);
                bzmOptions.put("blazemeter.sessionName", SESSION_NAME);
                bzmOptions.put("blazemeter.testName", TEST_NAME);

                chromeOptions.setCapability("bzm:options", bzmOptions);

                // setting up the JSON string needed...
                JSONObject bzmObj = new JSONObject();
                bzmObj.put("data", chromeOptions.toJson());

                // now processing the resulting JSON string prior to calling the final call
                HttpClient client = HttpClient.newHttpClient();
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(URI.create(CURL_PROXY))
                        .POST(HttpRequest.BodyPublishers.ofString(bzmObj.toJSONString()))
                        .header("Content-Type", "application/json")
                        .header("Authorization", getBasicAuthenticationHeader(API_KEY, API_SECRET))
                        .build();

                HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

                //System.out.println("chromeOptions as JSONObject: " + bzmObj.toJSONString());
                //System.out.println("this is a test" + response.body());

                // now we are going to process the resulting response.body()
                String bzmResProcess = response.body();
                //System.out.println("the bzmResProcess string: " + bzmResProcess);

                org.json.JSONObject bzmResObj = new org.json.JSONObject(bzmResProcess);
                org.json.JSONObject bzmExecObj = new org.json.JSONObject(bzmResObj.get("executor").toString());

                // updating the bzmoptions map with the new values
                bzmOptions.put("blazemeter.reportId", bzmResObj.get("reportId").toString());
                bzmOptions.put("blazemeter.parentSessionId", bzmResObj.getString("parentSessionId"));




                String proxyBlzGrid = bzmExecObj.getString("url");

                System.out.println("The proxy URL: " + proxyBlzGrid);
                System.out.println("Updated bzmOptions: " + bzmOptions.toString());
                System.out.println("Updated chromeOptions: " + chromeOptions.toString());

                //driver = new RemoteWebDriver(new URL(CURL), chromeOptions);
                // now starting the driver based off the newly launched BlazeGrid locally
                driver = new RemoteWebDriver(new URL(proxyBlzGrid), chromeOptions);

                browser_chrome_pub_rep_dict.put("grid_sessionId", new String(String.valueOf(driver.getSessionId())));
                browser_chrome_pub_rep_dict.put("grid_proxy_sessionId", bzmResObj.getString("parentSessionId"));
                browser_chrome_pub_rep_dict.put("grid_reportId", bzmResObj.get("reportId").toString());
                browser_chrome_pub_rep_dict.put("projectId", Integer.toString(PROJECT_ID));


                ProcessBLZReport chrome_browser_pub_rep = new ProcessBLZReport();
                String chrome_browser_pub_rep_link = chrome_browser_pub_rep.process_blzgrid_session(browser_chrome_pub_rep_dict);
                System.out.println("The public BlazeMeter testcase URL: " + chrome_browser_pub_rep_link);
                blzTableaddRow("chrome", chrome_browser_pub_rep_link);

                // now launching the browser to monitor the functional test
                //String chromeReportURL = String.format("https://%s/api/v4/grid/sessions/%s/redirect/to/report", BASE,
                //        driver.getSessionId());
                //String master_reportId = bzmResObj.get("reportId").toString();
                String chromeReportURL = String.format("https://%s/app/#/masters/%s", BASE,
                        bzmResObj.get("reportId").toString());

                System.out.println("Report url: " + chromeReportURL);
                openInBrowser(chromeReportURL);
                driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);

            }

            if (browser_name.equals("firefox") | browser_name.equals("all")) {
                System.out.println("The browser being called is firefox for this example");

                // setting up the firefox options to be used
                SESSION_NAME = "Session Selenium Firefox JAVA";
                TEST_NAME = "Selenium Firefox JAVA Grid Test";

                bzmOptions.put("blazemeter.sessionName", SESSION_NAME);
                bzmOptions.put("blazemeter.testName", TEST_NAME);

                firefoxOptions.setBrowserVersion("default");
                firefoxOptions.setCapability("bzm:options", bzmOptions);
                driver = new RemoteWebDriver(new URL(CURL), firefoxOptions);

                browser_firefox_pub_rep_dict.put("grid_sessionId", new String(String.valueOf(driver.getSessionId())));

                ProcessBLZReport firefox_browser_pub_rep = new ProcessBLZReport();
                String firefox_browser_pub_rep_link = firefox_browser_pub_rep.process_blzgrid_session(browser_firefox_pub_rep_dict);
                System.out.println("The public BlazeMeter testcase URL: " + firefox_browser_pub_rep_link);
                blzTableaddRow("firefox", firefox_browser_pub_rep_link);

                // now launching the browser to monitor the functional test
                String firefoxReportURL = String.format("https://%s/api/v4/grid/sessions/%s/redirect/to/report", BASE,
                        driver.getSessionId());
                System.out.println("Report url: " + firefoxReportURL);
                openInBrowser(firefoxReportURL);
                driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);

            }

            if (browser_name.equals("edge") | browser_name.equals("all")) {
                System.out.println("The browser being called is MS Edge for this example");

                // setting up the MS Edge options to be used
                SESSION_NAME = "Session Selenium MS Edge JAVA";
                TEST_NAME = "Selenium MS Edge JAVA Grid Test";

                bzmOptions.put("blazemeter.sessionName", SESSION_NAME);
                bzmOptions.put("blazemeter.testName", TEST_NAME);

                msedgeOptions.setBrowserVersion("default");
                msedgeOptions.setCapability("bzm:options", bzmOptions);
                driver = new RemoteWebDriver(new URL(CURL), msedgeOptions);

                browser_msedge_pub_rep_dict.put("grid_sessionId", new String(String.valueOf(driver.getSessionId())));

                ProcessBLZReport msedge_browser_pub_rep = new ProcessBLZReport();
                String msedge_browser_pub_rep_link = msedge_browser_pub_rep.process_blzgrid_session(browser_msedge_pub_rep_dict);
                System.out.println("The public BlazeMeter testcase URL: " + msedge_browser_pub_rep_link);
                blzTableaddRow("edge", msedge_browser_pub_rep_link);

                // now launching the browser to monitor the functional test
                String firefoxReportURL = String.format("https://%s/api/v4/grid/sessions/%s/redirect/to/report", BASE,
                        driver.getSessionId());
                System.out.println("Report url: " + firefoxReportURL);
                openInBrowser(firefoxReportURL);
                driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);

            }

            browser_counter = browser_counter + 1;

        }

    }

    private static void process_configFile(String controlFile) throws Exception
    {

        // the JSONParser object to parse the file after being read
        JSONParser blz_jsonParser = new JSONParser();

        try
        {
            File fileControl = new File(controlFile);

            if (fileControl.exists() && !fileControl.isDirectory())
            {
                Object blz_obj = blz_jsonParser.parse (new FileReader(fileControl));

                // Read JSON file
                JSONObject read_obj = (JSONObject) blz_obj;

                String scrambled_api_key = (String) read_obj.get("blz_api_key");
                API_KEY = unscrambled_value(scrambled_api_key);

                String scrambled_api_secret = (String) read_obj.get("blz_api_secret");
                API_SECRET = unscrambled_value(scrambled_api_secret);

                //String scrambled_harbor_id
                HARBOR_ID = (String) read_obj.get("blz_location_id");

                String scrambled_project_id = (String) read_obj.get("blz_project_id");
                PROJECT_ID = Integer.parseInt(unscrambled_value(scrambled_project_id));


                System.out.println("Project ID: " + PROJECT_ID);

                // processing the browser types to be used into different variables
                String blz_browser = (String) read_obj.get("blz_browser");
                BLZ_BROWSER_LIST = Arrays.asList(blz_browser.split(",",-1));

                BLZ_RPT_FILEPATH = (String) read_obj.get("blz_rpt_file_path");

            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ParseException e) {
            e.printStackTrace();
        }

    }

    private static String getBuildId() {
        var now= LocalDateTime.now();
        return "run" + now.getMonthValue() + now.getHour() + now.getMinute() + now.getSecond();
    }

    private static String unscrambled_value(String scrambledValue)
    {
        // decoding the Base64 value...
        byte[] scrambledBytes = scrambledValue.getBytes(StandardCharsets.UTF_8);
        byte[] decodedBytes = Base64.getDecoder().decode(scrambledBytes);
        String decodedString = new String(decodedBytes);
        return  decodedString;

    }

    private static final String getBasicAuthenticationHeader(String username, String password) {
        String valueToEncode = username + ":" + password;
        return "Basic " + Base64.getEncoder().encodeToString(valueToEncode.getBytes());
    }
    public static void openInBrowser(String string) {
        if (java.awt.Desktop.isDesktopSupported()) {
            try {
                java.awt.Desktop.getDesktop().browse(new URI(string));
            } catch (Exception ex) {
                LOGGER.warn("Failed to open in browser", ex);
            }
        }
    }

    public static void blzReportTable(String blz_report) throws IOException {

        // now defining the table that will be used...
        htmlStringBuilder.append("<html><head><title>"+blz_report+"</title></head>");

        htmlStringBuilder.append("<body><h1>BlazeMeter generated report links for distribution</h1>");
        htmlStringBuilder.append("<table border=\"1\" bordercolor=\"#000000\">");

    }

    public static void blzTable(String entry) {

        // creating the table that needs to be built
        htmlStringBuilder.append(entry);
        htmlStringBuilder.append("<table border=\"1\" bordercolor=\"#000000\">");

    }

    public static void blzTableaddRow (String browser_type, String entry) {

        if (browser_type.equals("chrome")) {
            htmlStringBuilder.append("<tr><td>Chrome </td><td><a href=" + entry + " target=\"_blank\" >BlazeMeter test run results</a></td>");
            htmlStringBuilder.append("</table></body></html>");
        }

        if (browser_type.equals("firefox")) {
            htmlStringBuilder.append("<tr><td>Firefox </td><td><a href=" + entry + " target=\"_blank\" >BlazeMeter test run results</a></td>");
            htmlStringBuilder.append("</table></body></html>");

        }

    }

    public static void blzWriteRptFile(String fileContent, String fileName) throws IOException {

        String tempFile = BLZ_RPT_FILEPATH + File.separator + fileName;
        File file = new File(tempFile);

        OutputStream outputStream = new FileOutputStream(file.getAbsoluteFile());
        //OutputStream outputStream = new FileOutputStream(file.getAbsoluteFile(), true);
        Writer writer=new OutputStreamWriter(outputStream);

        writer.write(fileContent);
        writer.close();

    }
    @AfterClass
    public static void tearDown() throws IOException {
        if (driver != null) {
            driver.quit();
        }

        if (chrome_driver != null) {
            chrome_driver.quit();
        }

        if (firefox_driver != null) {
            firefox_driver.quit();
        }

        // closing the html log file...
        try {
            // prior to closing the file, we are going to add a timestamp value to make it unique.
            String dateFormat = DateTime.now().toString("yyyyMMddHHmmss");
            String fileSeparator = ".";
            String blzFileName = "blz_rpt_links_"+dateFormat+".html";

            blzWriteRptFile(htmlStringBuilder.toString(),blzFileName);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    // adding the testcases to execute...
    @Test
    //@Given("Positive Tests")
    public void testCasePassed() {
        driver.get("http://blazedemo.com");
        driver.findElement(By.name("toPort")).click();
        Select toPort = new Select(driver.findElement(By.name("toPort")));
        toPort.selectByVisibleText("Berlin");
        driver.findElement(By.cssSelector("input.btn.btn-primary")).click();
    }

    @Test
    public void testCasesFailed() {

        driver.get("http://blazedemo.com/purchase.php");
        driver.findElement(By.id("inputName")).clear();
        driver.findElement(By.id("inputName")).sendKeys("TestName");
        String text = driver.findElement(By.id("inputName")).getAttribute("value");

        // failed assertion
        assertEquals("testName", text);

    }

    @Test
    public void testCaseBroken() {
        driver.get("http://blazedemo.com/purchase.php");
        WebElement city = driver.findElement(By.id("city"));
        city.click();
        city.sendKeys("NY");
        String text = driver.findElement(By.id("city")).getAttribute("value");
        if ("NY".equals(text)) {
            throw new RuntimeException("BZM grid script throws an exception");
        }

    }
}

