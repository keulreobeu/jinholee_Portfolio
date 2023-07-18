library(dplyr)
library(ggplot2)

df2019 <- read.csv('R프로젝트문제/NHIS_INCHON_2019.csv')
df2020 <- read.csv('R프로젝트문제/NHIS_INCHON_2020.csv')
format <- read.csv('R프로젝트문제/서식코드.csv')
age <- read.csv('R프로젝트문제/연령대코드.csv')
disease <- read.csv('R프로젝트문제/주상병코드.csv')
medical <- read.csv('R프로젝트문제/진료과목코드.csv')

df <- rbind(df2019, df2020)

age.df.2019 <- df2019[, c('가입자.일련번호', '연령대코드')]
duplicated_rows <- duplicated(age.df.2019)
age.df.2019 <- age.df.2019[!duplicated_rows, ]


age.df.2020 <- df2020[, c('가입자.일련번호', '연령대코드')]
duplicated_rows <- duplicated(age.df.2020)
age.df.2020 <- age.df.2020[!duplicated_rows, ]


format
age
disease
medical


# ==========================================================================

age_counts <- data.frame(table(age.df.2019$연령대코드))
age_counts$연령대 <- age$연령대[age_counts$Var1]
age_counts$연령대 <- factor(age_counts$연령대, levels = unique(age_counts$연령대))


ggplot(age_counts, aes(x = 연령대, y = Freq)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(x = "연령대", y = "수진자 수") +
  theme_minimal()

# ==========================================================================

top_10_codes <- head(sort(table(df2019$진료과목코드), decreasing = TRUE), 10)


colnames(medical)[1] <- "진료과목코드"

top_10_codes_df <- merge(data.frame(진료과목코드 = as.integer(names(top_10_codes)), count = as.integer(top_10_codes)), medical, by = "진료과목코드")


ggplot(top_10_codes_df, aes(x = count, y = reorder(진료과, count))) +
  geom_bar(stat = "identity", fill = "steelblue") +
  ylab("진료과목") +
  xlab("진료횟수") +
  ggtitle("진료과별 진료횟수") +
  scale_x_continuous(breaks =seq(0, 250001, 50000)) +
  theme(axis.text.y = element_text(angle = 0, hjust = 1))


# ==========================================================================


age.table.2019 <- table(age.df.2019$연령대코드)
names(age.table.2019) <- age$연령대

age.table.2020 <- table(age.df.2020$연령대코드)
names(age.table.2020) <- age$연령대

age_df_2019 <- data.frame(연령대 = names(age.table.2019), 수진자_수 = as.numeric(age.table.2019))

age_df_2020 <- data.frame(연령대 = names(age.table.2020), 수진자_수 = as.numeric(age.table.2020))


# 연령대 순서를 지정한 벡터 생성
age_order <- c("0~4세", "5~9세", "10~14세", "15~19세", "20~24세", "25~29세",
               "30~34세", "35~39세", "40~44세", "45~49세", "50~54세", "55~59세",
               "60~64세", "65~69세", "70~74세", "75~79세", "80~84세", "85세+")

# age_df_2019에서 연령대를 팩터로 변환하고 순서 지정
age_df_2019$연령대 <- factor(age_df_2019$연령대, levels = age_order)

# age_df_2020에서 연령대를 팩터로 변환하고 순서 지정
age_df_2020$연령대 <- factor(age_df_2020$연령대, levels = age_order)


ggplot() +
  geom_line(data = age_df_2019, aes(x = 연령대, y = 수진자_수, group = 1, color = "2019"), size = 1, alpha = 0.5) +
  geom_line(data = age_df_2020, aes(x = 연령대, y = 수진자_수, group = 1, color = "2020"), size = 1, alpha = 0.5) +
  geom_point(data = age_df_2019, aes(x = 연령대, y = 수진자_수, color = "2019"), size = 5, alpha = 0.5) +
  geom_point(data = age_df_2020, aes(x = 연령대, y = 수진자_수, color = "2020"), size = 5, alpha = 0.5) +
  labs(x = "연령대", y = "수진자_수", color = "연도") +
  scale_color_manual(values = c("2019" = "tomato", "2020" = "steelblue"), labels = c("2019", "2020")) +
  ggtitle("연도별 수진자 연령대 분포") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))



# ==========================================================================

medical.2019.table <- table(df2019$진료과목코드)
medical.2019.df <- as.data.frame(medical.2019.table)
medical.2019.df$진료과 <- medical$진료과[match(names(medical.2019.table), medical$진료과목코드)]
medical.2019.df


medical.2020.table <- table(df2020$진료과목코드)
medical.2020.df <- as.data.frame(medical.2020.table)
medical.2020.df$진료과 <- medical$진료과[match(names(medical.2020.table), medical$진료과목코드)]
medical.2020.df


ggplot() +
  geom_line(data = medical.2019.df, aes(x = 진료과, y = Freq, color = "2019년", group = 1), size = 1, alpha = 0.5) +
  geom_line(data = medical.2020.df, aes(x = 진료과, y = Freq, color = "2020년", group = 1), size = 1, alpha = 0.5) +
  geom_point(data = medical.2019.df, aes(x = 진료과, y = Freq, color = "2019년", group = 1), size = 5, alpha = 0.5) +
  geom_point(data = medical.2020.df, aes(x = 진료과, y = Freq, color = "2020년", group = 1), size = 5, alpha = 0.5) +
  ggtitle("연도별 진료과별 진료횟수 분포") +
  scale_color_manual(values = c("2019년" = "tomato", "2020년" = "steelblue"), labels = c("2019년", "2020년")) +
  labs(color = "연도") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

