sinon = require "sinon"
chai = require("chai")
chai.should()
{ObjectId} = require "mongojs"
async = require "async"

DocstoreClient = require "./helpers/DocstoreClient"

describe "Getting all docs", ->
	beforeEach (done) ->
		@project_id = ObjectId()
		@docs = [{
			_id: ObjectId()
			lines: ["one", "two", "three"]
			rev: 2
		}, {
			_id: ObjectId()
			lines: ["aaa", "bbb", "ccc"]
			rev: 4
		}, {
			_id: ObjectId()
			lines: ["111", "222", "333"]
			rev: 6
		}]
		@deleted_doc = {
			_id: ObjectId()
			lines: ["deleted"]
			rev: 8
		}
		version = 42
		ranges = 42
		jobs = for doc in @docs
			do (doc) =>
				(callback) => 
					DocstoreClient.createDoc @project_id, doc._id, doc.lines, version, ranges, callback
		jobs.push (cb) =>
			DocstoreClient.createDoc @project_id, @deleted_doc._id, @deleted_doc.lines, version, {}, (err)=>
					DocstoreClient.deleteDoc @project_id, @deleted_doc._id, cb
		async.series jobs, done 

	it "should return all the (non-deleted) docs", (done) ->
		DocstoreClient.getAllDocs @project_id, (error, res, docs) =>
			throw error if error?
			docs.length.should.equal @docs.length
			for doc, i in docs
				doc.lines.should.deep.equal @docs[i].lines
			done()


