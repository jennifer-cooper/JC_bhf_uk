#-----------------------------------------------------
#Code for searching TRE dictionary for relevant terms
#-----------------------------------------------------
install.packages("stringr")
library(stringr)
install.packages("dplyr")
library(dplyr)
#-----------------------------------------------------
#Read in all available SNOMED Concept IDs
#This is  obtained from the following webpage:
#https://digital.nhs.uk/coronavirus/gpes-data-for-pandemic-planning-and-research/guide-for-analysts-and-users-of-the-data

library(readxl)
GP_data_dictionary <- read_excel("GP data dictionary 03 11 2020.xlsx")
View(GP_data_dictionary)
summary(GP_data_dictionary)
#All strings
#-----------------------------------------------------
#Looking for birth or pregnancy terms to add to a list
#Use str_detect to identify these from the Concept ID Description variable
#A dot with star matches any character for any given number of characters, ignore_case means it does not matter about upper and lower case matches

GP_data_dictionary$case_keep<- str_detect(GP_data_dictionary$ConceptId_Description, 
                                                     regex("birth.*|pregnan.*", ignore_case = TRUE))                

#-----------------------------------------------------
#Filter the cases which have been identified:

GP_data_dictionary %>% 
  filter(case_keep==TRUE) %>% 
  View()


#-----------------------------------------------------
#There may be duplicates as the concept code may be present in multiple clusters

GP_data_dictionary %>% 
  filter(case_keep==TRUE) %>% 
  select(ConceptId, ConceptId_Description) %>% 
  distinct(ConceptId_Description, .keep_all = T) %>% 
  View()

subset_case<- GP_data_dictionary %>% 
  filter(case_keep==TRUE) %>% 
  select(ConceptId, ConceptId_Description, case_keep) %>% 
  distinct(ConceptId_Description, .keep_all = T)

#Review this list (ideally double review with a clinician)
#For any that may need to be excluded

#-----------------------------------------------------
#To remove the ones you do not want to include
#Can either specify row numbers or remove any mention of a particular string

#e.g. if you did not want the alcohol related codes included:

subset_case$case_remove<- str_detect(subset_case$ConceptId_Description, regex("alcohol.*", ignore_case = TRUE))

#Final list
subset_case %>% 
  filter(case_keep==TRUE & case_remove==FALSE) %>% 
  select(ConceptId, ConceptId_Description) %>% 
  distinct(ConceptId_Description, .keep_all = T) %>% 
  View()
#-----------------------------------------------------
#Alternatively specify the row numbers you want to remove

subset_case <- subset_case %>% 
mutate(row_number = row_number())

subset_case$case_remove<- str_detect(subset_case$ConceptId_Description, regex("alcohol.*", ignore_case = TRUE))

#e.g. removing the row mentioning alcohol

final_list  %>% 
  filter(row_number!=1) %>% 
  View()

#-----------------------------------------------------  
#Write as file  
#-----------------------------------------------------  

