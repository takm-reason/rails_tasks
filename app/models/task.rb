class Task < ApplicationRecord
  before_create :set_uuid

  validates :title, presence: true
  validates :priority, inclusion: { in: 0..2 }

  scope :ordered_by_priority, -> { order(priority: :desc, created_at: :desc) }
  scope :ordered_by_due_date, -> { order(due_date: :asc, created_at: :desc) }
  scope :completed, -> { where(is_completed: true) }
  scope :uncompleted, -> { where(is_completed: false) }

  def complete!
    update!(
      is_completed: true,
      completed_at: Time.current
    )
  end

  def uncomplete!
    update!(
      is_completed: false,
      completed_at: nil
    )
  end

  def as_json(options = {})
    super(options.merge(
      methods: [:priority_text],
      except: [:updated_at],
      include: {}
    ))
  end

  def priority_text
    case priority
    when 0 then 'low'
    when 1 then 'medium'
    when 2 then 'high'
    end
  end

  def completed?
    self[:is_completed]
  end

  def self.priority_values
    {
      low: 0,
      medium: 1,
      high: 2
    }
  end

  private

  def set_uuid
    self.id = SecureRandom.uuid if id.nil?
  end
end
