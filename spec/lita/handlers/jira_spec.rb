require 'spec_helper'

describe Lita::Handlers::Jira, lita_handler: true do
  it { routes_command('todo some text').to(:todo) }
  it { routes_command('jira issue assignee ABC-123').to(:issue_assignee_list) }
  it { routes_command('jira issue assignee ABC-123 foo@example.com').to(:issue_assignee_set) }
  it { routes_command('jira issue attachments ABC-123').to(:issue_attachments_list) }
  it { routes_command('jira issue attachments ABC-123 http://example.com').to(:issue_attachments_set) }
  it { routes_command('jira issue comments ABC-123').to(:issue_comments_list) }
  it { routes_command('jira issue comments ABC-123 Some text').to(:issue_comments_add) }
  it { routes_command('jira issue details ABC-123').to(:issue_details) }
  it { routes_command('jira issue issuetype ABC-123').to(:issue_issuetype_list) }
  it { routes_command('jira issue issuetype ABC-123 4').to(:issue_issuetype_set) }
  it { routes_command('jira issue new ABC some:thing').to(:issue_new) }
  it { routes_command('jira issue notify ABC-123').to(:issue_notify_list) }
  it { routes_command('jira issue notify ABC-123 foo@example.com').to(:issue_notify_set) }
  it { routes_command('jira issue priority ABC-123').to(:issue_priority_list) }
  it { routes_command('jira issue priority ABC-123 9').to(:issue_priority_set) }
  it { routes_command('jira issue summary ABC-123').to(:issue_summary_list) }
  it { routes_command('jira issue summary ABC-123 Some text!').to(:issue_summary_set) }
  it { routes_command('jira issue watchers ABC-123').to(:issue_watchers_list) }
  it { routes_command('jira issue watchers ABC-123 foo@example.com').to(:issue_watchers_set) }
  it { routes_command('jira issuetype list ABC').to(:issuetype_list) }
  it { routes_command('jira search Some text').to(:search_full) }
  it { routes_command('jira search ABC Some text').to(:search_project) }
  it { routes_command('jira identify foo@example.com').to(:identify) }
  it { routes_command('jira forget').to(:forget) }
  it { routes_command('jira whoami').to(:whoami) }
  it { routes_command('jira default project ABC').to(:default_project) }
  it { routes_command('jira default priority 9').to(:default_priority) }

  describe '.default_config' do
    it 'sets username to nil' do
      expect(Lita.config.handlers.jira.username).to be_nil
    end

    it 'sets password to nil' do
      expect(Lita.config.handlers.jira.password).to be_nil
    end

    it 'sets site to nil' do
      expect(Lita.config.handlers.jira.site).to be_nil
    end

    it 'sets context to nil' do
      expect(Lita.config.handlers.jira.context).to be_nil
    end
  end

  describe '#issue_summary' do
    it 'with valid issue ID shows summary' do
      response = double(summary: 'Some summary text')
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(response)
      send_command('jira XYZ-987')
      expect(replies.last).to eq('XYZ-987: Some summary text')
    end

    it 'without valid issue ID shows an error' do
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(nil)
      send_command('jira XYZ-987')
      expect(replies.last).to eq('Error fetching JIRA issue')
    end
  end

  describe '#issue_details' do
    it 'with valid issue ID shows details' do
      response = double(summary: 'Some summary text',
                        assignee: double(displayName: 'A Person'),
                        priority: double(name: 'P0'),
                        status: double(name: 'In Progress'))
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(response)
      send_command('jira XYZ-987 details')
      expect(replies.last).to eq('XYZ-987: Some summary text, assigned to: ' \
                                 'A Person, priority: P0, status: In Progress')
    end

    it 'without valid issue ID shows an error' do
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(nil)
      send_command('jira XYZ-987 details')
      expect(replies.last).to eq('Error fetching JIRA issue')
    end
  end
end
