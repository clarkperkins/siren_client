require 'helper/live_spec_helper'

URL = 'http://localhost:9292'
describe HTTParty do
  it 'will be blocked by basic auth' do
    expect(HTTParty.get(URL).code).to eq(401)
  end
  it 'can access the server' do
    expect(HTTParty.get(URL, basic_auth: { username: 'admin', password: '1234' }).code).to eq(200)
  end
end

describe SirenClient do
  context 'when creating an entity' do
    let (:headers_ent) { 
      SirenClient.get({
        url: URL,
        basic_auth: { username: 'admin', password: '1234' },
        headers: { "Accept" => "application/json" }
      })
    }
    it 'can set HTTP headers' do
      expect {
        expect(headers_ent.config[:headers]).to be_a Hash
        expect(headers_ent.config[:headers]).to eq({ 
          "Accept" => "application/json"
        })
      }.to_not raise_error
    end
    it 'it\'s actions inherit the same config' do
      expect(headers_ent.filter_concepts_get.config[:headers]).to eq({
        "Accept" => "application/json"
      })
    end
  end

  let (:client) { 

    SirenClient.get(
      url: URL, 
      timeout: 2,
      basic_auth: { username: 'admin', password: '1234' },
      headers: { "Accept" => "application/json" },
      debug_output: $stdout
    ) 
  }
  context 'when accessing the root entity' do
    it 'to return an entity' do
      expect(client).to be_a SirenClient::Entity
    end
    it 'to access properties' do
      expect(client.properties['name']).to eq('Test 1')
    end
    it 'to not have entities' do
      expect(client.length).to eq(0)
    end
  end
  context 'when accessing a link' do
    it 'to return a link' do
      expect(client.links['concepts']).to be_a SirenClient::Link
    end
    it 'to follow the link' do
      byebug
      expect(client.concepts).to be_a SirenClient::Entity
      expect(client.concepts.links['self'].href).to eq(URL + '/concepts')
    end
  end
  context 'when accessing an action with GET' do
    it 'to return an action' do
      expect(client.filter_concepts_get).to be_a SirenClient::Action
    end
    context 'with .where' do
      it 'to execute the action' do
        params = { search: 'obama' }
        expect(client.filter_concepts_get.where(params)).to be_a SirenClient::Entity
        expect(client.filter_concepts_get.where(params).length).to eq(1)
        expect(client.filter_concepts_get.where(params)[0]).to be_a SirenClient::Entity
        expect(client.filter_concepts_get.where(params)[0].category).to eq('PERSON')
      end
    end
  end
  context 'when accessing an action with POST' do
    it 'to return an action' do
      expect(client.filter_concepts_post).to be_a SirenClient::Action
    end
    context 'with .where' do
      it 'to execute the action' do
        params = { search: 'obama' }
        expect(client.filter_concepts_post.where(params)).to be_a SirenClient::Entity
        expect(client.filter_concepts_post.where(params).length).to eq(1)
        expect(client.filter_concepts_post.where(params)[0]).to be_a SirenClient::Entity
        expect(client.filter_concepts_post.where(params)[0].category).to eq('PERSON')
      end
    end
  end

  let (:concepts) { SirenClient.get({ url: URL, basic_auth: { username: 'admin', password: '1234' }}).concepts }
  context 'when accessing an entity' do
    it 'to return an entity' do
      expect(concepts).to be_a SirenClient::Entity
    end
  end
end
