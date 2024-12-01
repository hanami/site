Hanami.app.configure_provider :db do
  after :start do
    # Automatically migrate our in-memory SQLite database when the db starts
    slice["db.gateways.default"].auto_migrate! slice["db.config"], inline: true
  end
end
