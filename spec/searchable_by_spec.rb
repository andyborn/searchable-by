require 'spec_helper'

describe ActiveRecord::SearchableBy do
  let(:alice) { AUTHORS[:alice] }
  let(:bob)   { AUTHORS[:bob] }

  it 'should have config' do
    expect(Post.send(:_searchable_by_config).count).to eq(3)
  end

  it 'should ignore bad inputs' do
    expect(Post.search_by(nil).count).to eq(4)
    expect(Post.search_by('').count).to eq(4)
  end

  it 'should generate SQL' do
    sql = Post.search_by('123').to_sql
    expect(sql).to include(%("posts"."id" = 123))
    expect(sql).to include(%(LOWER("posts"."title") LIKE '%123%'))

    sql = Post.search_by('foo%bar').to_sql
    expect(sql).not_to include(%("posts"."id"))
    expect(sql).to include(%(LOWER("posts"."title") LIKE '%foo\\%bar%'))
  end

  it 'should search' do
    expect(Post.search_by('ALICE').pluck(:title)).to match_array(%w[titla title])
    expect(Post.search_by('bOb').pluck(:title)).to match_array(%w[titlo titlu])
  end

  it 'should search integers' do
    expect(Post.search_by(POSTS[:alice1].id.to_s).count).to eq(1)
  end
end
