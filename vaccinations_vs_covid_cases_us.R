library(dplyr)
library(ggplot2)

covid_cases <- readr::read_csv(
  "~/Downloads/united_states_covid19_cases_deaths_and_testing_by_state.csv",
  skip=2,
)


covid_cases <- covid_cases[, c('State/Territory', 'Case Rate per 100000')]
str(covid_cases)

vaccinations <- readr::read_csv(
  "~/Downloads/covid19_vaccinations_in_the_united_states.csv",
  skip=2,
)
vaccinations <- vaccinations[, c('State/Territory/Federal Entity', 'Percent of 12+ Pop Fully Vaccinated by State of Residence')]
str(vaccinations)


merged_data <- merge(
  vaccinations, 
  covid_cases,
  by.x='State/Territory/Federal Entity',
  by.y='State/Territory',
)
str(merged_data)
merged_data['state'] <- merged_data['State/Territory/Federal Entity']
merged_data['case_rate_100K'] <- merged_data['Case Rate per 100000']
merged_data['pct_vaxx'] <- merged_data['Percent of 12+ Pop Fully Vaccinated by State of Residence']
merged_data <- merged_data %>%
  filter(!is.na(case_rate_100K)) %>%
  filter(pct_vaxx > 0) %>%
  mutate(case_rate_100K = as.integer(case_rate_100K))

# merged_data %>% filter(pct_vaxx == 0)

plt <- ggplot(merged_data, aes(pct_vaxx, case_rate_100K, label=state)) + 
  geom_point(alpha = 0.5, size = 3) +
  geom_text(alpha=0.3, size=2, nudge_y=500) +
  xlab('Percent of 12+ Pop Fully Vaccinated by State of Residence') +
  ylab('Case Rate per 100000')

ggplot2::ggsave("percent_vaccinated_vs_case_rate.pdf", plt, width=8, height=4)