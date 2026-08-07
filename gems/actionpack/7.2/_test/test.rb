class FooController < ActionController::Base
  allow_browser versions: :modern
end

class BarController < ActionController::Base
  allow_browser versions: { safari: 17.5, chrome: 127, ie: false }, block: -> { head :not_acceptable }
end

ActionController::Base.new.render_to_string(template: 'foo', locals: { bar: 'baz' })

class FooService
  include ActionDispatch::Routing::RouteSet.new.url_helpers
end

parameters = ActionController::Parameters.new

# Every filter shape `permit_filters` acts on, nested to depth.
parameters.permit(:title, 'body').permitted?
parameters.permit(:title, tags: []).permitted?
parameters.permit(:title, person: [:name, :age, { address: [:city] }]).permitted?
parameters.permit(preferences: {}).permitted?
parameters.permit([:title, 'body']).permitted?
allowed = [:title, :body]
parameters.permit(*allowed).permitted?

parameters.with_defaults(page: 1).permitted?
parameters.with_defaults({ 'page' => 1 }).permitted?
parameters.with_defaults!(page: 1).permitted?
