history_hh <- function()
{
    #library("devtools")
    #install_github('konoanalytics/KonostdlibR')
    library("KonostdlibR")
    
    # from http://www.eia.gov/dnav/ng/hist/rngwhhdd.htm
    hh_history <- read.csv('~/publicdata/Henry_Hub_Natural_Gas_Spot_Price.csv', skip=4, stringsAsFactors = FALSE, colClasses = c('character','numeric'))
    hh_history$Day <- as.Date(hh_history$Day,format='%m/%d/%Y')
    hh_history$source <- 'http://www.eia.gov/dnav/ng/hist/rngwhhdd.htm'
    hh_history$latestread <- 1
    hh_history$updatedatetime <- as.POSIXlt(Sys.time(), tz='utc')
    unitid <- as.integer(KonostdlibR::runmysql("select id from KonoDev.tbl_units where unit = '$/mmbtu'"))
    hh_history$id_units <- unitid
    hh_history <- KonostdlibR::changedfnames(hh_history, 'Henry.Hub.Natural.Gas.Spot.Price.Dollars.per.Million.Btu','price')
    hh_history
}

uploadinitial_hh <- function()
{
    #library("devtools")
    #install_github('konoanalytics/KonostdlibR')
    library("KonostdlibR")
    loadpackage("RMySQL")
    
    df <- history_hh()
    
    user <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$userid)
    password <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$password)
    host <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$host)
    dbname <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$dbname)
    con <- RMySQL::dbConnect(MySQL(),user=user, password=password, host=host, dbname=dbname)
    RMySQL::dbWriteTable(conn=con, name="tbl_hhdailysettle", value=df, row.names=FALSE)
}

getlatest_hh <- function(writefile=FALSE, pathfilename="/temp/hh_history.csv")
{
    #library("devtools")
    #install_github('konoanalytics/KonostdlibR')
    library("KonostdlibR")
    loadpackage("RMySQL")
    
    #user <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$userid)
    #password <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$password)
    #host <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$host)
    #dbname <- as.character(KonostdlibR::getcredentials("AWSMySQLSandbox")$dbname)
    #con <- RMySQL::dbConnect(MySQL(),user=user, password=password, host=host, dbname=dbname)

    df <- KonostdlibR::runmysql("select hh.Day, hh.price, hh.updatedatetime, u.unit from tbl_hhdailysettle as hh left join tbl_units as u on hh.id_units = u.id where latestread = 1 order by day asc")
    if(writefile)
    {
        write.csv(df, pathfilename,row.names = FALSE)
    }
    df
}