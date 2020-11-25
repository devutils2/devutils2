//
//  BackslashEscapeTool.swift
//  DevUtils2
//
//  Created by Tony Dinh on 8/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import JavaScriptCore

class BackslashEscapeToolOptions: ToolOptions {
}

class BackslashEscapeTool: EndecodeTool {
  
  override func hasSetting() -> Bool {
    return false
  }
  
  override func isSampleNeedEncode() -> Bool {
    return false
  }
  
  override func getSampleString() -> String? {
    return """
    Example values: \\n\\tallow.auto.create.topics = true\\n\\tauto.commit.interval.ms = 5000\\n\\tauto.offset.reset = latest\\n\\tbootstrap.servers = [kafka.service.consul:9092]\\n\\tcheck.crcs = true\\n\\tclient.dns.lookup = default\\n\\tclient.id = \\n\\tclient.rack = \\n\\tconnections.max.idle.ms = 540000\\n\\tdefault.api.timeout.ms = 60000\\n\\tenable.auto.commit = true\\n\\texclude.internal.topics = true\\n\\tfetch.max.bytes = 52428800\\n\\tfetch.max.wait.ms = 500\\n\\tfetch.min.bytes = 1\\n\\tgroup.id = sample-devutils2\\n\\tgroup.instance.id = null\\n\\theartbeat.interval.ms = 3000\\n\\tinterceptor.classes = []\\n\\tinternal.leave.group.on.close = true\\n\\tisolation.level = read_uncommitted\\n\\tkey.deserializer = class org.apache.kafka.common.serialization.StringDeserializer\\n\\tmax.partition.fetch.bytes = 1048576\\n\\tmax.poll.interval.ms = 300000\\n\\tmax.poll.records = 500\\n\\tmetadata.max.age.ms = 300000\\n\\tmetrics.num.samples = 2\\n\\tmetrics.recording.level = INFO\\n\\tmetrics.sample.window.ms = 30000\\n\\tpartition.assignment.strategy = [class org.apache.kafka.clients.consumer.RangeAssignor]\\n\\treceive.buffer.bytes = 65536\\n\\treconnect.backoff.max.ms = 1000\\n\\treconnect.backoff.ms = 50\\n\\trequest.timeout.ms = 30000\\n\\tretry.backoff.ms = 100\\n\\tsasl.client.callback.handler.class = null\\n\\tsasl.jaas.config = null\\n\\tsasl.kerberos.kinit.cmd = /usr/bin/kinit\\n\\tsasl.kerberos.min.time.before.relogin = 60000\\n\\tsasl.kerberos.service.name = null\\n\\tsasl.kerberos.ticket.renew.jitter = 0.05\\n\\tsasl.kerberos.ticket.renew.window.factor = 0.8\\n\\tsasl.login.callback.handler.class = null\\n\\tsasl.login.class = null\\n\\tsasl.login.refresh.buffer.seconds = 300\\n\\tsasl.login.refresh.min.period.seconds = 60\\n\\tsasl.login.refresh.window.factor = 0.8\\n\\tsasl.login.refresh.window.jitter = 0.05\\n\\tsasl.mechanism = GSSAPI\\n\\tsecurity.protocol = SSL\\n\\tsecurity.providers = null\\n\\tsend.buffer.bytes = 131072\\n\\tsession.timeout.ms = 10000\\n\\tssl.cipher.suites = null\\n\\tssl.enabled.protocols = [TLSv1.2, TLSv1.1, TLSv1]\\n\\tssl.endpoint.identification.algorithm = \\n\\tvalue.deserializer = class org.apache.kafka.common.serialization.StringDeserializer\\n
    """
  }
  
  override func getEncodeLabel() -> String {
    return "Escape"
  }
  
  override func getDecodeLabel() -> String {
    return "Unescape"
  }
  
  override func encode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    return String(input.debugDescription.dropFirst().dropLast())
  }
  
  override func decode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    return input.unescaped
  }
}

