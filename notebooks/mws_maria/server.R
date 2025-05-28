
function(input, output, session) {

  custom_theme = theme(
    title = element_text(size = 20),
    axis.title.x = element_text(size = 18),
    axis.text.x = element_text(size = 16),
    axis.title.y = element_text(size = 18))
  
  output$opsTable <- DT::renderDT({
    plot_data <- hours_ops
    
    # if (input$process != "ALL"){
    #   
    #   plot_data <- hours_ops |> 
    #     filter(short_description == input$process)
    # }
    plot_data |> 
      DT::datatable(
        colnames = c("Process" = "short_description", 
                     "Number of Jobs" = "num_jobs", 
                     "Total Hours" = "total_hours", 
                     "Average Hours" = "avg_hr",
                     "Average Difference between Estimated and Actual Hours" = 'avg_hr_diff')
      )
  })
  
  output$opsChart <- renderPlot ({
    
    title <- "Summary of Processes"
    
    plot_data <- hours_ops_longer
    
    # if (input$process != "ALL"){
    #   
    #   plot_data <- hours_ops_longer |> 
    #     filter(short_description == input$process)
    # }
    plot_data |> 
      ggplot(aes(x=factor(short_description, level=c('ZINC_PLATE', 
                                                     'POWDER_COAT', 
                                                     'GALVANIZE', 
                                                     'WELD', 
                                                     'PART_TRANSFER',
                                                     'MACHINE',
                                                     'TURRET_PUNCH',
                                                     'OTHER',
                                                     'PRESS_BRAKE',
                                                     'SAW',
                                                     'LASER',
                                                     'PACK',
                                                     'SET_UP')), 
                 y = hours, 
                 fill = measurement)) +
      geom_col(position='dodge') +
      scale_x_discrete(guide = guide_axis(angle = 90)) +
      theme(legend.title = element_blank()) +
      scale_fill_hue(labels = c("Average Total Hours", "Average Difference in Hours (Est v Act)")) +
      labs(
        title = title,
        x = "Process",
        y = 'Hours'
      ) +
      custom_theme
  })
  
  output$partsTable <- DT::renderDT({
    hours_parts |>
      DT::datatable(
        colnames = c("Part ID" = "part_id", 
                     "Number of Parts" = "num_parts", 
                     "Total Hours" = "total_hours", 
                     "Average Hours" = "avg_hr",
                     "Average Difference between Estimated and Actual Hours" = 'avg_hr_diff')
      )
  })
  
  output$partsChart <- renderPlot ({
    
    title <- "Avg Difference between Estimated and Actual Production Hours"
    
    hours_parts |> 
      ggplot(aes(x=factor(part_id, level=c('Y002-0562',
                                           'C057-0000I',
                                           'U013-0001',
                                           'S046-0169',
                                           'F022-0007',
                                           'S046-0156',
                                           'M030-0004')), 
                 y=avg_hr_diff)) +
      geom_col() +
      scale_x_discrete(guide = guide_axis(angle = 90)) +
      labs(
        title = title,
        x = 'Part ID',
        y = 'Difference in Hours'
      ) +
      custom_theme
    
  })

}
