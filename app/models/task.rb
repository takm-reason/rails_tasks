class Task < ApplicationRecord
  before_create :set_uuid
  before_save :sync_completion_status

  validates :title, presence: true

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2
  }, default: :medium

  scope :ordered_by_priority, -> { 
    order(priority: :desc, created_at: :desc)
  }

  scope :ordered_by_due_date, -> { 
    order(Arel.sql("CASE WHEN due_date IS NULL THEN 1 ELSE 0 END, due_date ASC, created_at DESC"))
  }

  scope :completed, -> { 
    where.not(completed_at: nil)
  }

  scope :uncompleted, -> { 
    where(completed_at: nil)
  }

  def complete!
    update!(completed_at: Time.current)
  end

  def uncomplete!
    update!(completed_at: nil)
  end

  def completed?
    completed_at.present?
  end

  def as_json(options = {})
    super(options.merge(
      except: [:updated_at, :is_completed],
      include: {}
    ))
  end

  private

  def set_uuid
    self.id = SecureRandom.uuid if id.nil?
  end

  def sync_completion_status
    self.is_completed = completed_at.present?
    true
  end
end
