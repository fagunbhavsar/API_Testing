module MailCatcherHelper

  def mailcatcher_clear()
    driver.find_element(:link_text, "Clear").click
    sleep 1
    a = driver.switch_to.alert
    a.accept
  end

  def mailcatcher_open_message_from_top(idx = 0)
    message_rows = driver.find_elements(:xpath, "//nav[@id='messages']/table/tbody/tr")
    message_rows[idx].click
  end

  def mailcatcher_open_message(idx = 1)
    driver.find_element(:xpath, "//tr[@data-message-id='#{idx}']").click
    sleep 1
  end

  def mailcatcher_message_from
    driver.find_element(:xpath, "//dl[@class='metadata']/dd[@class='from']").text
  end

  def mailcatcher_message_to
    driver.find_element(:xpath, "//dl[@class='metadata']/dd[@class='to']").text
  end

  def mailcatcher_message_subject
    driver.find_element(:xpath, "//dl[@class='metadata']/dd[@class='subject']").text
  end

  def mailcatcher_message_text
    sleep 0.5
    driver.switch_to.frame(0)
    message_body = ""
    begin
      message_body = driver.find_element(:tag_name, "body").text
    ensure
      driver.switch_to.default_content
      return message_body
    end
  end

  def mailcatcher_search(q)
    search_elem = driver.find_element(:name, "search")
    search_elem.send_keys(q)
    search_elem.clear
    search_elem.send_keys(:tab)
    sleep 1
  end
  
end
