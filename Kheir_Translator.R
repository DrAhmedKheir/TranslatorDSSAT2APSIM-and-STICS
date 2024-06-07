# Load necessary library
library(stringr)
#DSSAT2APSIM
# Define file paths
input_file <- "D:/Translator/ASWN1301.WTH"
output_file <- "D:/Translator/Translatedapsim/ASWN.met"

# Read the DSSAT .WTH file
wth_data <- readLines(input_file)

# Extract metadata
metadata <- str_subset(wth_data, "^@|^\\*|^[^0-9]")
data <- str_subset(wth_data, "^[0-9]")

# Extract metadata information
lat <- as.numeric(str_extract(metadata[2], "\\s[0-9]+\\.[0-9]+"))
lon <- as.numeric(str_extract(metadata[2], "-[0-9]+\\.[0-9]+"))
elev <- as.numeric(str_extract(metadata[2], "(?<=\\s)[0-9]+\\.[0-9]+(?=\\s[0-9]+\\.[0-9]+)"))
tav <- as.numeric(str_extract(metadata[2], "(?<=\\s)[0-9]+\\.[0-9]+(?=\\s[0-9]+\\.[0-9]+)"))
amp <- as.numeric(str_extract(metadata[2], "(?<=\\s)[0-9]+\\.[0-9]+(?=\\s[0-9]+\\.[0-9]+)"))

# Create a dataframe for weather data
weather_data <- read.table(text = data, header = FALSE, col.names = c("DATE", "SRAD", "TMAX", "TMIN", "RAIN"))

# Convert DATE to year and day format
weather_data$YEAR <- as.numeric(substr(weather_data$DATE, 1, 2)) + 2000
weather_data$DAY <- as.numeric(substr(weather_data$DATE, 3, 5))

# Write to APSIM .met format
sink(output_file)
cat("[weather.met.weather]\n")
cat("!station number = 123\n")
cat(sprintf("!latitude = %.2f\n", lat))
cat(sprintf("!longitude = %.2f\n", lon))
cat(sprintf("!tav = %.1f\n", tav))
cat(sprintf("!amp = %.1f\n", amp))
cat("\n[weather.met.weather.data]\n")
cat("year  day  radn  maxt  mint  rain\n")
write.table(weather_data[, c("YEAR", "DAY", "SRAD", "TMAX", "TMIN", "RAIN")], 
            row.names = FALSE, col.names = FALSE, sep = "  ", quote = FALSE)
sink()

# Close the sink
sink(NULL)



##############DSSAT2STICS
# Define file paths
input_file <- "D:/Translator/ASWN1301.WTH"
output_file <- "D:/Translator/Translated2stics/ASWN.2013"

# Read the DSSAT .WTH file
wth_data <- readLines(input_file)

# Extract metadata
metadata <- str_subset(wth_data, "^@|^\\*|^[^0-9]")
data <- str_subset(wth_data, "^[0-9]")

# Create a dataframe for weather data
weather_data <- read.table(text = data, header = FALSE, col.names = c("DATE", "SRAD", "TMAX", "TMIN", "RAIN"))

# Convert DATE to year, month, day, and Julian day format
weather_data$YEAR <- as.numeric(substr(weather_data$DATE, 1, 2)) + 2000
weather_data$JDAY <- as.numeric(substr(weather_data$DATE, 3, 5))
weather_data$MONTH <- as.numeric(format(as.Date(weather_data$JDAY, origin = paste0(weather_data$YEAR, "-01-01")), "%m"))
weather_data$DAY <- as.numeric(format(as.Date(weather_data$JDAY, origin = paste0(weather_data$YEAR, "-01-01")), "%d"))

# Create the STICS format dataframe
stics_data <- data.frame(
  FILENAME = rep("ASWN.2013", nrow(weather_data)),
  YEAR = weather_data$YEAR,
  MONTH = weather_data$MONTH,
  DAY = weather_data$DAY,
  JDAY = weather_data$JDAY,
  TMIN = weather_data$TMIN,
  TMAX = weather_data$TMAX,
  SRAD = weather_data$SRAD,
  PET = rep(-999.0, nrow(weather_data)),  # Penman PET (optional)
  RAIN = weather_data$RAIN,
  WIND = rep(-999.0, nrow(weather_data)), # Wind (optional)
  VAP = rep(-999.0, nrow(weather_data)),  # Vapour pressure (optional)
  CO2 = rep(-999.0, nrow(weather_data))   # CO2 content (optional)
)

# Write to the STICS format file without header
write.table(stics_data, output_file, row.names = FALSE, col.names = FALSE, sep = "\t", quote = FALSE)
