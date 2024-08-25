library(openxlsx)
library(ggplot2)

#windowsFonts(TNR=windowsFont("Times New Roman"))


data = read.xlsx("figure3.xlsx")
data$var = factor(data$var,levels = unique(data$var))
data$type = factor(data$type,levels = unique(data$type))
data$mtype = factor(data$mtype,levels = unique(data$mtyp))
data$Coefficients = factor(data$Coefficients,levels = unique(data$Coefficients))

options(repr.plot.width = 5, repr.plot.height =200)

ggplot(data,aes(x=mtype,y=coef,color=Coefficients))+
  geom_errorbar(aes(ymin = lb, ymax = ub),
                position = position_dodge(0.6),
                width = 0, linewidth = 1.5)+
  geom_hline(yintercept=0,linewidth = 1,linetype = 2,color="black")+
  geom_point(aes(shape=Coefficients),position = position_dodge(0.6),size=4)+ ## shape=label 按照变量label设置不同的shape
  geom_point(position = position_dodge(0.6),size=3)+
  facet_grid(cols = vars(type), rows = vars(var), 
             scales = "free",space="free_x")+
  scale_color_manual(values=c("lightcoral","#619CFF"))+
  scale_shape_manual(values = c(16,18))+ ## 手动设置shape，16为实心圆，18为实心菱形
  theme_bw()+
  theme(
    axis.ticks.length.y = unit(-0.15, 'cm'), #设置y轴的刻度长度为负数，如果x和y轴都要，那么
    axis.ticks.length = unit(-0.15, 'cm'),
    panel.border = element_blank(),
    axis.title = element_blank(),
    axis.text.x = element_text(size =12,color = "black",angle = 45,hjust=1),
    axis.text.y = element_text(size =12,color = "black"),
    axis.line.x = element_line(color="black",linewidth=0.1),
    axis.line.y = element_line(color="black",linewidth=0.1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.spacing = unit(0.2, "cm", data = NULL), 
    strip.background = element_rect(color="black",fill="white",linewidth=1),
    strip.text = element_text(size = 12),
    legend.position="bottom")

