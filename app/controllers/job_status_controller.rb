class JobStatusController < ApplicationController
  # GET /job_status/:job_id
  def show
    # Intentar buscar el job en la base de datos de Sidekiq
    # Nota: Esto requiere la gema 'sidekiq-status' para funcionar correctamente
    job_id = params[:id]

    # Si usas sidekiq-status
    if defined?(Sidekiq::Status)
      status = Sidekiq::Status.status(job_id)
      if status
        render json: { job_id:, status: }
      else
        render json: { error: 'Job not found or completed' }, status: :not_found
      end
    else
      # Alternativa básica si no tienes sidekiq-status
      # Esto solo comprobará si el job está en la cola, no su estado exacto
      job_in_queue = Sidekiq::Queue.new.any? { |job| job.jid == job_id }
      job_in_process = Sidekiq::Workers.new.any? { |_, _, work| work['payload']['jid'] == job_id }

      if job_in_queue || job_in_process
        render json: { job_id:, status: job_in_process ? 'processing' : 'queued' }
      else
        render json: { job_id:, status: 'completed or not found' }
      end
    end
  end
end
